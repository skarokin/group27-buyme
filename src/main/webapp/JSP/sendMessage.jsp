<%@ page import="java.sql.*" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    int chatID = Integer.parseInt(request.getParameter("chatID"));
    String message = request.getParameter("message");
    int currentUserID = (Integer) session.getAttribute("userID");
    try (Connection conn = new ApplicationDB().getConnection()) {
        // Insert the message
        String insertMessageSQL = "INSERT INTO messages (chatID, senderUserID, message) VALUES (?, ?, ?)";
        try (PreparedStatement insertMessageStmt = conn.prepareStatement(insertMessageSQL)) {
            insertMessageStmt.setInt(1, chatID);
            insertMessageStmt.setInt(2, currentUserID);
            insertMessageStmt.setString(3, message);
            insertMessageStmt.executeUpdate();
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    // Redirect back to the chat
    response.sendRedirect("chatRoom.jsp?chatID=" + chatID);
%>
