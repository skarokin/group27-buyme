<%@ page import="java.sql.*"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="com.cs336.pkg.ApplicationDB"%>

<%
    Integer loggedInUserId = (Integer) session.getAttribute("userID");
    if (loggedInUserId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String itemIDToBidStr = request.getParameter("itemIDToBid");
    String bidAmountStr = request.getParameter("bidAmount");
    String autoBidLimitStr = request.getParameter("autoBidLimit");
    String errorMessage = null; // Variable to hold error messages

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        conn = new ApplicationDB().getConnection();
        int itemIDToBid = Integer.parseInt(itemIDToBidStr);
        float bidAmount = Float.parseFloat(bidAmountStr);
        float autoBidLimit = autoBidLimitStr != null && !autoBidLimitStr.isEmpty() ? Float.parseFloat(autoBidLimitStr) : 0;

        // Fetch the maximum bid, initial price, and minBidIncrement for the item
        String bidInfoQuery = "SELECT COALESCE(MAX(b.bidAmount), i.initialPrice) AS maxBid, i.initialPrice, i.minBidIncrement FROM items i LEFT JOIN bids b ON b.itemID = i.itemID WHERE i.itemID = ? GROUP BY i.itemID";
        stmt = conn.prepareStatement(bidInfoQuery);
        stmt.setInt(1, itemIDToBid);
        rs = stmt.executeQuery();

        float maxBid = 0;
        int minBidIncrement = 0;
        if (rs.next()) {
            maxBid = rs.getFloat("maxBid");  // This will be the higher of initial price or max bid amount
            minBidIncrement = rs.getInt("minBidIncrement");
        }

        // Check if new bid is valid
        if (bidAmount >= maxBid + minBidIncrement) {  
            String insertBidQuery = "INSERT INTO Bids (itemId, userId, bidDate, bidAmount, autoBid) VALUES (?, ?, ?, ?, ?)";
            stmt = conn.prepareStatement(insertBidQuery);
            stmt.setInt(1, itemIDToBid);
            stmt.setInt(2, loggedInUserId);
            
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            String currentDate = dateFormat.format(new Date());
            stmt.setString(3, currentDate);

            stmt.setFloat(4, bidAmount);
            stmt.setFloat(5, autoBidLimit);
            int result = stmt.executeUpdate();

            if (result > 0) {
                // Update other bids if needed
                String updateBidsQuery = "UPDATE Bids SET bidAmount = LEAST(bidAmount + ?, autoBid) WHERE itemID = ? AND bidAmount < autoBid AND autoBid >= bidAmount + ?";
                stmt = conn.prepareStatement(updateBidsQuery);
                stmt.setFloat(1, minBidIncrement);
                stmt.setInt(2, itemIDToBid);
                stmt.setFloat(3, minBidIncrement);
                stmt.executeUpdate();
                
                response.sendRedirect("searchItems.jsp"); // Redirect to search or dashboard page
            } else {
                errorMessage = "Failed to place bid.";
            }
        } else {
            errorMessage = "Your bid must be higher than the current highest bid plus the minimum bid increment of $" + minBidIncrement;
        }
    } catch (SQLException e) {
        e.printStackTrace();
        errorMessage = "Error processing your bid.";
    } catch (NumberFormatException e) {
        errorMessage = "Invalid bid data provided.";
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (stmt != null) try { stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }

        if (errorMessage != null) {
            request.setAttribute("errorMessage", errorMessage);
            request.getRequestDispatcher("searchItems.jsp").forward(request, response);
        }
    }
%>