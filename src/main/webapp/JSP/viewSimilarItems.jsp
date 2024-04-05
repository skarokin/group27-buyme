<%@ page import="java.sql.*, java.util.ArrayList, java.util.HashMap" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    String category = request.getParameter("category");
    String currentItemID = request.getParameter("itemID");
    List<Map<String, Object>> similarItems = new ArrayList<>();

    try (Connection conn = new ApplicationDB().getConnection()) {
        String query = "SELECT * FROM Items WHERE category = ? AND itemID <> ? AND closeTime BETWEEN DATE_SUB(NOW(), INTERVAL 1 MONTH) AND NOW()";
        try (PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, category);
            ps.setInt(2, Integer.parseInt(currentItemID));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("title", rs.getString("title"));
                    item.put("initialPrice", rs.getFloat("initialPrice"));
                    item.put("userID", rs.getInt("userID"));
                    similarItems.add(item);
                }
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Similar Items</title>
</head>
<body>
    <h1>Similar Items</h1>
    <% for (Map<String, Object> item : similarItems) { %>
        <div>
            <h2><%= item.get("title") %></h2>
            <p>Initial Price: $<%= item.get("initialPrice") %></p>
        </div>
    <% } %>
    <a href="searchItems.jsp">Back to Search</a>
</body>
</html>