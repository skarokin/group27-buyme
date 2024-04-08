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
    <h1>BuyMe Dashboard</h1>

    <a href="<%=request.getContextPath()%>/JSP/logout.jsp" class="link-button">Logout</a>
    <a href="<%=request.getContextPath()%>/JSP/delete.jsp" class="link-button">Delete Account</a>