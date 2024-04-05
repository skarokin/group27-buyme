<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<!DOCTYPE html>
<html>
<head>
    <title>BuyMe Dashboard</title>
    <style>
        body {
            text-align: center;
            font-family: Arial, sans-serif;
            margin-top: 50px;
        }
        .link-button {
            display: inline-block;
            background-color: #007bff;
            color: white;
            padding: 10px 20px;
            margin: 10px;
            text-decoration: none;
            border-radius: 5px;
            transition: background-color 0.3s;
        }
        .link-button:hover {
            background-color: #0056b3;
        }
         .action-button {
            display: inline-block;
            background-color: #007bff;
            color: white;
            padding: 10px 20px;
            margin: 10px;
            text-decoration: none;
            border-radius: 5px;
            transition: background-color 0.3s;
        }
        .action-button:hover {
            background-color: #0056b3;
        }
        table {
            margin-top: 20px;
            margin-left: auto;
            margin-right: auto;
            border-collapse: collapse;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
        }
        th {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
    <%
        Integer userId = (Integer) session.getAttribute("userID");
    %>
    <h2>Welcome to BuyMe</h2>

    <a href="<%=request.getContextPath()%>/JSP/listItemForm.jsp" class="link-button">List an Item</a>
    <a href="<%=request.getContextPath()%>/JSP/searchItems.jsp" class="link-button">Search Items</a>
    <a href="<%=request.getContextPath()%>/JSP/setAlertsForm.jsp" class="link-button">Set Alerts</a>
    <form action="<%=request.getContextPath()%>/JSP/userAuctionsBids.jsp" method="post">
        <input type="hidden" name="userID" value="<%= userId %>">
        <button type="submit" class="action-button">View My Bids/Auctions</button>
    </form>
    <a href="<%=request.getContextPath()%>/JSP/logout.jsp" class="link-button">Logout</a>
    <a href="<%=request.getContextPath()%>/JSP/delete.jsp" class="link-button">Delete Account</a>

    <h2>Your Alerts</h2>
    <table>
        <tr>
            <th>Make</th>
            <th>Model</th>
            <th>Year</th>
            <th>Color</th>
            <th>Status</th>
            <th>Action</th>
        </tr>
        <%
            if (userId != null) {
                try (Connection conn = new ApplicationDB().getConnection()) {
                    String queryAlerts = "SELECT * FROM alerts WHERE userID = ?";
                    PreparedStatement psAlerts = conn.prepareStatement(queryAlerts);
                    psAlerts.setInt(1, userId);
                    ResultSet rsAlerts = psAlerts.executeQuery();
                    
                    while (rsAlerts.next()) {
                        String make = rsAlerts.getString("make");
                        String model = rsAlerts.getString("model");
                        int yom = rsAlerts.getInt("yom");
                        String color = rsAlerts.getString("color");
                        int alertID = rsAlerts.getInt("alertID");
                        boolean isMatchFound = false;

                        String queryAuctions = "SELECT COUNT(*) AS matchCount FROM items WHERE make = ? AND model = ? AND yom = ? AND color = ? AND closeTime > NOW()";
                        PreparedStatement psAuctions = conn.prepareStatement(queryAuctions);
                        psAuctions.setString(1, make);
                        psAuctions.setString(2, model);
                        psAuctions.setInt(3, yom);
                        psAuctions.setString(4, color);
                        ResultSet rsAuctions = psAuctions.executeQuery();
                        if (rsAuctions.next()) {
                            isMatchFound = rsAuctions.getInt("matchCount") > 0;
                        }

                        %>
                        <tr>
                            <td><%= make %></td>
                            <td><%= model %></td>
                            <td><%= yom %></td>
                            <td><%= color %></td>
                            <td><%= isMatchFound ? "<span style='color: green;'>Match Found!</span>" : "Pending" %></td>
                            <td>
                                <form action="<%=request.getContextPath()%>/JSP/deleteAlert.jsp" method="post">
                                    <input type="hidden" name="alertID" value="<%= alertID %>">
                                    <input type="submit" value="Delete">
                                </form>
                            </td>
                        </tr>
                        <%
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            } else {
                out.println("<tr><td colspan='6'>No alerts to display. Please log in.</td></tr>");
            }
        %>
    </table>
    </body>
</html>
