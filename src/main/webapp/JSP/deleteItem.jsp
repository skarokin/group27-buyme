<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<html>
<head>
    <title>Item Deletion Status</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f4f4f4;
            text-align: center;
        }
        .message {
            background-color: #dff0d8;
            color: #3c763d;
            padding: 20px;
            margin-bottom: 20px;
            border: 1px solid #d6e9c6;
            border-radius: 4px;
            display: inline-block;
        }
        .error {
            background-color: #f2dede;
            color: #a94442;
            padding: 20px;
            margin-bottom: 20px;
            border: 1px solid #ebccd1;
            border-radius: 4px;
            display: inline-block;
        }
        a {
            display: inline-block;
            background-color: #337ab7;
            color: white;
            padding: 10px 15px;
            margin: 5px;
            text-decoration: none;
            border-radius: 4px;
        }
        a:hover {
            background-color: #286090;
        }
    </style>
</head>
<body>
<%
    Integer userId = (Integer) session.getAttribute("userID");
    String userRole = (String) session.getAttribute("userRole");
    String itemId = request.getParameter("itemID");
    if (userId == null || itemId == null) {
        response.sendRedirect("login.jsp");
    } else {
        boolean deletionSuccess = false;
        try (Connection conn = new ApplicationDB().getConnection()) {
            String sql = "DELETE FROM Items WHERE itemID = ?";
            if (!"custRep".equals(userRole) && !"admin".equals(userRole)) {
                sql += " AND userId = ?";
            }
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, itemId);
            if (!"custRep".equals(userRole) && !"admin".equals(userRole)) {
                stmt.setInt(2, userId);
            }
            int affectedRows = stmt.executeUpdate();
            if (affectedRows > 0) {
                deletionSuccess = true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        if (deletionSuccess) {
            %>
            <div class="message">
                <h1>Item Deleted Successfully!</h1>
                <p>The item has been successfully removed from the auction.</p>
            </div>
            <%
        } else {
            %>
            <div class="error">
                <h1>Error Deleting Item</h1>
                <p>Item not found, or you do not have permission to delete this item.</p>
            </div>
            <%
        }
    }
%>
<a href="dashboard.jsp">Return to Dashboard</a>
<a href="searchItems.jsp">Continue Browsing</a>
</body>
</html>