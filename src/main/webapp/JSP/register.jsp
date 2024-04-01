<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String email = request.getParameter("email");
    boolean registrationSuccess = true;

    if ("POST".equalsIgnoreCase(request.getMethod()) && username != null && password != null && email != null) {
        try (Connection conn = new ApplicationDB().getConnection();
            PreparedStatement stmt = conn.prepareStatement("INSERT INTO users (username, password, email) VALUES (?, ?, ?)")) {            stmt.setString(1, username);
            stmt.setString(2, password);
            stmt.setString(3, email);
            if (stmt.executeUpdate() > 0) {
                response.sendRedirect(request.getContextPath() + "/JSP/login.jsp");
                return;
            }
        } catch (SQLException e) {
            registrationSuccess = false;
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Register</title>
</head>
<body>
	<h1>BuyMe</h1>
    <h2>Register</h2>
    <% if (!registrationSuccess) { %>
        <p>Registration failed.</p>
    <% } %>
    <form action="<%=request.getContextPath()%>/JSP/register.jsp" method="post">
        Username: <input type="text" name="username" required><br>
        Password: <input type="password" name="password" required><br>
        Email: <input type="email" name="email" required><br>
        <button type="submit">Register</button>
    </form>
    <a href="<%=request.getContextPath()%>/JSP/login.jsp">Login</a>
</body>
</html>
