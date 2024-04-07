<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%
    int itemId = Integer.parseInt(request.getParameter("itemId"));
    Float autoBidLimit = request.getParameter("autoBid") != null ? Float.parseFloat(request.getParameter("autoBid")) : null;
    Integer userId = (Integer) session.getAttribute("userID");

    if(autoBidLimit == null || userId == null) {
        return;
    }

    Connection conn = null;
    try {
        conn = new ApplicationDB().getConnection();
        conn.setAutoCommit(false); // Start transaction

        // Retrieve the highest auto-bid for comparison
        String getAutoBidQuery = "SELECT MAX(autoBid) AS maxAutoBid FROM Bids WHERE itemId = ?";
        PreparedStatement getAutoBidPs = conn.prepareStatement(getAutoBidQuery);
        getAutoBidPs.setInt(1, itemId);
        ResultSet autoBidRs = getAutoBidPs.executeQuery();
        
        float maxAutoBid = 0;
        if (autoBidRs.next()) {
            maxAutoBid = autoBidRs.getFloat("maxAutoBid");
        }
        
        // Check if the new auto-bid is higher than any existing auto-bids
        if (autoBidLimit <= maxAutoBid) {
            return;
        }

        // Set new auto-bid limit
        String setAutoBidQuery = "INSERT INTO Bids (itemId, userId, autoBid) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE autoBid = ?";
        PreparedStatement setAutoBidPs = conn.prepareStatement(setAutoBidQuery);
        setAutoBidPs.setInt(1, itemId);
        setAutoBidPs.setInt(2, userId);
        setAutoBidPs.setFloat(3, autoBidLimit);
        setAutoBidPs.setFloat(4, autoBidLimit);
        setAutoBidPs.executeUpdate();
        
        conn.commit(); // Commit transaction
        response.sendRedirect("bidSuccess.jsp?itemId=" + itemId);
    } catch (Exception e) {
        if (conn != null) try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
        e.printStackTrace();
    } finally {
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>