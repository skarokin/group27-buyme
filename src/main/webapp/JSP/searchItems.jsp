<%@ page import="java.sql.*, java.util.List, java.util.ArrayList, java.util.HashMap, java.util.Map" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%
    Integer loggedInUserId = (Integer) session.getAttribute("userID");
    String searchQuery = request.getParameter("searchQuery");
    List<Map<String, Object>> searchResults = new ArrayList<>();
    Map<Integer, Float> highestBids = new HashMap<>();
    Map<Integer, Float> initialPrices = new HashMap<>();

    if (searchQuery != null && !searchQuery.isEmpty()) {
        try (Connection conn = new ApplicationDB().getConnection()) {
            PreparedStatement stmt = conn.prepareStatement(
                "SELECT i.*, (SELECT MAX(bidAmount) FROM bids WHERE itemID = i.itemID) AS highestBid " +
                "FROM Items i WHERE title LIKE ?"
            );
            stmt.setString(1, "%" + searchQuery + "%");
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("itemID", rs.getInt("itemID"));
                row.put("title", rs.getString("title"));
                row.put("ownerID", rs.getInt("userID"));
                row.put("initialPrice", rs.getFloat("initialPrice"));
                row.put("highestBid", rs.getFloat("highestBid") == 0 ? rs.getFloat("initialPrice") : rs.getFloat("highestBid"));
                searchResults.add(row);
                initialPrices.put(rs.getInt("itemID"), rs.getFloat("initialPrice"));
                highestBids.put(rs.getInt("itemID"), rs.getFloat("highestBid") == 0 ? rs.getFloat("initialPrice") : rs.getFloat("highestBid"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    String itemIDToBidStr = request.getParameter("itemIDToBid");
    String bidAmountStr = request.getParameter("bidAmount");
    if (itemIDToBidStr != null && bidAmountStr != null && !itemIDToBidStr.isEmpty() && !bidAmountStr.isEmpty() && loggedInUserId != null) {
        int itemIDToBid = Integer.parseInt(itemIDToBidStr);
        float bidAmount = Float.parseFloat(bidAmountStr);

        try (Connection conn = new ApplicationDB().getConnection()) {
            String checkBidQuery = "SELECT MAX(bidAmount) AS maxBid FROM bids WHERE itemID = ?";
            PreparedStatement checkBidStmt = conn.prepareStatement(checkBidQuery);
            checkBidStmt.setInt(1, itemIDToBid);
            ResultSet rs = checkBidStmt.executeQuery();
            
            float maxBid = 0;
            if (rs.next()) {
                maxBid = rs.getFloat("maxBid");
            }

            if (bidAmount > maxBid) {
                PreparedStatement insertBidStmt = conn.prepareStatement(
                    "INSERT INTO Bids (itemId, userId, bidAmount) VALUES (?, ?, ?)");
                insertBidStmt.setInt(1, itemIDToBid);
                insertBidStmt.setInt(2, loggedInUserId);
                insertBidStmt.setFloat(3, bidAmount);
                insertBidStmt.executeUpdate();
                response.sendRedirect("bidSuccess.jsp?itemIDToBid=" + itemIDToBid);
            } else {
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Search Items</title>
    <style>
        .bid-history { display: none; position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background-color: white; border: 1px solid #000; padding: 20px; z-index: 2; }
        .overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.5); z-index: 1; }
    </style>
</head>
<body>
    <h1>Search for Items</h1>
    <form action="searchItems.jsp" method="post">
        Search Query: <input type="text" name="searchQuery" required><br>
        <button type="submit">Search</button>
    </form>

    <h2>Search Results:</h2>
    <% if (!searchResults.isEmpty()) { %>
        <ul>
        <% for (Map<String, Object> item : searchResults) { %>
            <li style="margin-bottom: 40px;">
                <%= item.get("title") %><br>
                Initial Price: $<%= item.get("initialPrice") %><br>
                Highest Bid: $<%= item.get("highestBid") %><br>
                <% if (!item.get("ownerID").equals(loggedInUserId)) { %>
                    <form action="searchItems.jsp" method="post">
                        <input type="hidden" name="itemIDToBid" value="<%= item.get("itemID") %>">
                        <input type="number" name="bidAmount" step="0.01" required>
                        <input type="submit" value="Place Bid">
                    </form>
                <% } else { %>
                    <form action="deleteItem.jsp" method="post">
                        <input type="hidden" name="itemID" value="<%= item.get("itemID") %>">
                        <input type="submit" value="Delete Listing" onclick="return confirm('Are you sure you want to delete this listing?');">
                    </form>
                <% } %>
                <a href="viewBidHistory.jsp?itemID=<%=item.get("itemID")%>" class="button-link">View Bids</a>
            </li>
        <% } %>
    </ul>
<% } else { %>
    <p>No results found.</p>
<% } %>
<a href="dashboard.jsp">Back to Dashboard</a>
</body>
</html>