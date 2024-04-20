<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>

<%
    String userIDParam = request.getParameter("userID");
    int userID = 0;
    String username = "";
    List<HashMap<String, String>> userActivities = new ArrayList<>();

    if (userIDParam != null && !userIDParam.isEmpty()) {
        userID = Integer.parseInt(userIDParam);
    }
    
    try (Connection conn = new ApplicationDB().getConnection()) {
    String updateBalanceQuery = "SELECT items.itemID, MAX(bidAmount) AS highestBid FROM bids INNER JOIN items ON bids.itemID = items.itemID WHERE items.userID = ? AND items.closeTime <= NOW() AND items.balanceUpdated = FALSE GROUP BY items.itemID";    PreparedStatement psUpdateBalance = conn.prepareStatement(updateBalanceQuery);
    psUpdateBalance.setInt(1, userID);
    ResultSet rsUpdateBalance = psUpdateBalance.executeQuery();

    float totalEarnings = 0;
    while (rsUpdateBalance.next()) {
        totalEarnings += rsUpdateBalance.getFloat("highestBid");
        String markProcessedQuery = "UPDATE items SET balanceUpdated = TRUE WHERE itemID = ?";
        PreparedStatement psMarkProcessed = conn.prepareStatement(markProcessedQuery);
        psMarkProcessed.setInt(1, rsUpdateBalance.getInt("itemID"));
        psMarkProcessed.executeUpdate();
    }

    if (totalEarnings > 0) {
        String updateUserBalanceQuery = "UPDATE users SET balance = balance + ?, totalEarned = totalEarned + ? WHERE userID = ?";
        PreparedStatement psUpdateUserBalance = conn.prepareStatement(updateUserBalanceQuery);
        psUpdateUserBalance.setFloat(1, totalEarnings);
        psUpdateUserBalance.setFloat(2, totalEarnings);
        psUpdateUserBalance.setInt(3, userID);
        psUpdateUserBalance.executeUpdate();
    }
    }

    try (Connection conn = new ApplicationDB().getConnection()) {
        String usernameQuery = "SELECT username FROM users WHERE userID = ?";
        try (PreparedStatement ps = conn.prepareStatement(usernameQuery)) {
            ps.setInt(1, userID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    username = rs.getString("username");
                }
            }
        }

        String userActivityQuery = "SELECT 'Bid' as activityType, b.bidAmount, b.autoBid, i.title, b.bidID, i.itemID, i.closeTime, i.closeTime <= NOW() as auctionEnded, (SELECT MAX(bidAmount) FROM bids WHERE itemID = b.itemID) as highestBid, b.userID = (SELECT userID FROM bids WHERE itemID = b.itemID ORDER BY bidAmount DESC, bidID ASC LIMIT 1) as isWinner FROM bids b INNER JOIN items i ON b.itemID = i.itemID WHERE b.userID = ? " +
                "UNION ALL " +
                "SELECT 'Auction' as activityType, i.initialPrice, NULL as autoBid, i.title, NULL as bidID, i.itemID, i.closeTime, i.closeTime <= NOW() as auctionEnded, (SELECT MAX(bidAmount) FROM bids WHERE itemID = i.itemID) as highestBid, FALSE as isWinner FROM items i WHERE i.userID = ?";
        try (PreparedStatement ps = conn.prepareStatement(userActivityQuery)) {
            ps.setInt(1, userID);
            ps.setInt(2, userID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    HashMap<String, String> activity = new HashMap<>();
                    activity.put("type", rs.getString("activityType"));
                    activity.put("amount", rs.getString("bidAmount") == null ? "N/A" : rs.getString("bidAmount"));
                    activity.put("autoBid", rs.getString("autoBid"));
                    activity.put("title", rs.getString("title"));
                    activity.put("itemID", rs.getString("itemID"));
                    activity.put("bidID", rs.getString("bidID") == null ? "N/A" : rs.getString("bidID"));
                    activity.put("auctionEnded", rs.getString("auctionEnded"));
                    activity.put("highestBid", rs.getString("highestBid") == null ? "N/A" : rs.getString("highestBid"));
                    activity.put("isWinner", rs.getString("isWinner"));
                    Timestamp closeTimestamp = rs.getTimestamp("closeTime");
                    String closeTimeString = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(closeTimestamp);
                    activity.put("closeTime", closeTimeString);
                    userActivities.add(activity);
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
    <title><%= username %>'s Bids/Auctions</title>
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        th, td {
            padding: 10px;
            border: 1px solid #ddd;
        }
        th {
            background-color: #f8f8f8;
        }
        .return-link {
            text-decoration: none;
            color: blue;
        }
    </style>
</head>
<body>
    <h1><%= username %>'s Bids/Auctions</h1>
<table>
    <tr>
        <th>Type</th>
        <th>Title</th>
        <th>Amount</th>
        <th>Bid Type</th> <!-- New column for Bid Type -->
        <th>Status</th>
        <th>Auction End Time</th>
        <th>Action</th>
    </tr>
    <% for (HashMap<String, String> activity : userActivities) {
    	String status = "Active";
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        Date currentTime = new Date();
        Date closeTime = sdf.parse(activity.get("closeTime"));
        
        if (closeTime.before(currentTime)) {
            status = "Auction Ended";
            if ("Bid".equals(activity.get("type"))) {
                if ("true".equals(activity.get("isWinner"))) {
                    status += " - Won";
                } else {
                    // Check if the user's bid is equal to the final winning bid
                    float userBid = Float.parseFloat(activity.get("amount"));
                    float highestBid = Float.parseFloat(activity.get("highestBid"));
                    if (userBid == highestBid) {
                        status += " - Lost";
                    }
                }
            }
        }
    %>
    
    <tr>
        <td><%= activity.get("type") %></td>
    	<td><%= activity.get("title") %></td>
    	<td><%= activity.get("amount") %></td>
    	<td><%= activity.get("autoBid") != null && Float.parseFloat(activity.get("autoBid")) == 0 ? "Manual Bid" : (activity.get("autoBid") == null ? "N/A" : "Auto-bid, max: " + activity.get("autoBid")) %></td>
    	<td><%= status %></td>
    	<td><%= activity.get("closeTime") %></td>
        <td>
            <% if ("Bid".equals(activity.get("type"))) { %>
                <form action="deleteBid.jsp" method="post">
                    <input type="hidden" name="bidID" value="<%= activity.get("bidID") %>">
                    <button type="submit">Withdraw Bid</button>
                </form>
            <% } else { %>
                <form action="deleteItem.jsp" method="post">
                    <input type="hidden" name="itemID" value="<%= activity.get("itemID") %>">
                    <button type="submit">Delete Auction</button>
                </form>
            <% } %>
        </td>
    </tr>
    <% } %>
</table>

    <a href="<%=request.getContextPath()%>/JSP/dashboard.jsp" class="return-link">Back to Dashboard</a>
</body>
</html>

