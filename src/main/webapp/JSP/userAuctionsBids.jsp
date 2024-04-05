<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    String userIDParam = request.getParameter("userID");
    int userID = 0;
    String username = "";
    List<HashMap<String, String>> userActivities = new ArrayList<>();

    if (userIDParam != null && !userIDParam.isEmpty()) {
        userID = Integer.parseInt(userIDParam);
    }

    try (Connection conn = new ApplicationDB().getConnection()) {
        String usernameQuery = "SELECT username FROM Users WHERE userID = ?";
        try (PreparedStatement ps = conn.prepareStatement(usernameQuery)) {
            ps.setInt(1, userID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    username = rs.getString("username");
                }
            }
        }

        String userActivityQuery = "SELECT 'Bid' as activityType, b.bidAmount, i.title FROM bids b INNER JOIN items i ON b.itemID = i.itemID WHERE b.userID = ? " +
                                   "UNION ALL " +
                                   "SELECT 'Auction' as activityType, i.initialPrice, i.title FROM items i WHERE i.userID = ?";
        try (PreparedStatement ps = conn.prepareStatement(userActivityQuery)) {
            ps.setInt(1, userID);
            ps.setInt(2, userID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    HashMap<String, String> activity = new HashMap<>();
                    activity.put("type", rs.getString("activityType"));
                    activity.put("amount", rs.getString("bidAmount"));
                    activity.put("title", rs.getString("title"));
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
        </tr>
        <% for (HashMap<String, String> activity : userActivities) { %>
            <tr>
                <td><%= activity.get("type") %></td>
                <td><%= activity.get("title") %></td>
                <td>$<%= activity.get("amount") %></td>
            </tr>
        <% } %>
    </table>

    <a href="<%=request.getContextPath()%>/JSP/dashboard.jsp" class="return-link">Back to Search</a>
</body>
</html>