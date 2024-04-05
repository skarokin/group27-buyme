<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    Integer loggedInUserId = (Integer) session.getAttribute("userID");
    if (loggedInUserId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String itemIDParam = request.getParameter("itemID");
    List<HashMap<String, String>> bidHistory = new ArrayList<>();
    List<HashMap<String, String>> userAuctions = new ArrayList<>();
    List<HashMap<String, String>> similarItems = new ArrayList<>();
    HashMap<String, String> initialBid = new HashMap<>();
    String currentItemTitle = "";
    int itemID = 0;

    if (itemIDParam != null && !itemIDParam.isEmpty()) {
        itemID = Integer.parseInt(itemIDParam);
    }

    try (Connection conn = new ApplicationDB().getConnection()) {
        String currentItemTitleQuery = "SELECT title FROM Items WHERE itemID = ?";
        try (PreparedStatement ps = conn.prepareStatement(currentItemTitleQuery)) {
            ps.setInt(1, itemID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    currentItemTitle = rs.getString("title");
                }
            }
        }

        String bidHistoryQuery = "SELECT b.bidAmount, b.bidDate, u.username, u.userID FROM bids b INNER JOIN users u ON b.userID = u.userID WHERE b.itemID = ? ORDER BY b.bidAmount DESC";
        try (PreparedStatement ps = conn.prepareStatement(bidHistoryQuery)) {
            ps.setInt(1, itemID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    HashMap<String, String> bid = new HashMap<>();
                    bid.put("amount", rs.getString("bidAmount"));
                    bid.put("date", rs.getString("bidDate"));
                    bid.put("user", rs.getString("username"));
                    bid.put("userID", rs.getString("userID"));
                    bidHistory.add(bid);
                }
            }
        }


        String initialBidQuery = "SELECT u.username, i.initialPrice, u.userID FROM Items i INNER JOIN Users u ON i.userID = u.userID WHERE i.itemID = ?";
        try (PreparedStatement ps = conn.prepareStatement(initialBidQuery)) {
            ps.setInt(1, itemID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    initialBid.put("user", rs.getString("username"));
                    initialBid.put("amount", rs.getString("initialPrice"));
                    initialBid.put("creatorUserID", rs.getString("userID"));
                }
            }
        }

    } catch (SQLException e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>View Bid History</title>
</head>
<body>
    <h1>Bid History for: <%= currentItemTitle %></h1>
    
    <% if (!initialBid.isEmpty()) { %>
        <p>Initial Price by <a href="userAuctionsBids.jsp?userID=<%= initialBid.get("creatorUserID") %>"><%= initialBid.get("user") %></a>: $<%= initialBid.get("amount") %></p>
    <% } %>
    
    <% for (HashMap<String, String> bid : bidHistory) { %>
        <p><a href="userAuctionsBids.jsp?userID=<%= bid.get("userID") %>"><%= bid.get("user") %></a> bid $<%= bid.get("amount") %> on <%= bid.get("date") %></p>
    <% } %>

    <a href="searchItems.jsp">Back to Search</a>
</body>
</html>