<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    boolean loginSuccess = true;

    if ("POST".equalsIgnoreCase(request.getMethod()) && username != null && password != null) {
        try (Connection conn = new ApplicationDB().getConnection();
             PreparedStatement stmt = conn.prepareStatement("SELECT * FROM users WHERE username = ? AND password = ?")) {
            stmt.setString(1, username);
            stmt.setString(2, password);
            ResultSet rs = stmt.executeQuery();
            loginSuccess = rs.next();
            rs.close();
        } catch (SQLException e) {
        }
        if (loginSuccess) {
            session.setAttribute("user", username);
            response.sendRedirect(request.getContextPath() + "/JSP/landingPage.jsp");
            return;
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
</head>
<body>
	<h1>BuyMe</h1>
    <h2>Login</h2>
    <% if (!loginSuccess && "POST".equalsIgnoreCase(request.getMethod())) { %>
        <p>Login failed.</p>
    <% } %>
    <form action="<%=request.getContextPath()%>/JSP/login.jsp" method="post">
        Username: <input type="text" name="username" required><br>
        Password: <input type="password" name="password" required><br>
        <button type="submit">Login</button>
    </form>
    <a href="<%=request.getContextPath()%>/JSP/register.jsp">Register</a>
</body>
</html>
