<%@ page import="java.sql.*, java.util.HashMap, java.util.ArrayList"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Search and Modify User Information</title>
    <style>
        body {
            text-align: center;
            font-family: Arial, sans-serif;
            margin-top: 50px;
        }
        input[type="text"], input[type="password"] {
            padding: 10px;
            margin: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            width: 250px;
        }
        .action-button, .reset-button {
            display: inline-block;
            background-color: #007bff;
            color: white;
            padding: 10px 20px;
            margin: 10px;
            text-decoration: none;
            border-radius: 5px;
            transition: background-color 0.3s;
        }
        .action-button:hover, .reset-button:hover {
            background-color: #0056b3;
        }
        .user-link {
            color: #007bff;
            text-decoration: underline;
        }
        .user-link:hover {
            text-decoration: none;
        }
        .user-entry {
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <h1>Search and Modify User Information</h1>
    <form action="" method="get">
        Username: <input type="text" name="search" required>
        <button type="submit" class="action-button">Search</button>
    </form>
    <%

    String searchQuery = request.getParameter("search");
    if (searchQuery != null && !searchQuery.isEmpty()) {
        try (Connection conn = new ApplicationDB().getConnection()) {
            String query = "SELECT userID, username FROM users WHERE username LIKE ? AND role = 'user'";
            try (PreparedStatement ps = conn.prepareStatement(query)) {
                ps.setString(1, "%" + searchQuery + "%");
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        %>
                        <div class="user-entry">
                            <a href="<%=request.getContextPath()%>/JSP/userAuctionsBids.jsp?userID=<%= rs.getInt("userID") %>" class="user-link"><%= rs.getString("username") %></a>
                            <form action="<%=request.getContextPath()%>/JSP/resetPassword.jsp" method="post" style="display: inline;">
                                <input type="hidden" name="userID" value="<%= rs.getInt("userID") %>">
                                New Password: <input type="password" name="newPassword" required>
                                <button type="submit" class="reset-button">Reset Password</button>
                            </form>
                        </div>
                        <%
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<p>Error during the search. Please try again.</p>");
        }
    }
    %>
    <a href="<%=request.getContextPath()%>/JSP/dashboard.jsp" class="action-button">Back to Dashboard</a>
</body>
</html>
