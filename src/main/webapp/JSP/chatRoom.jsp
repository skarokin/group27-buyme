<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer currentUserID = (Integer) session.getAttribute("userID");
    String partnerUsername = request.getParameter("partnerUsername");
    int chatID = -1;

    if (currentUserID == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Connection conn = null;
    try {
        conn = new ApplicationDB().getConnection();
        if (partnerUsername != null && !partnerUsername.trim().isEmpty()) {
            int partnerUserID = -1;
            String getUserIdSQL = "SELECT userID FROM users WHERE username = ?";
            PreparedStatement getUserIdStmt = conn.prepareStatement(getUserIdSQL);
            getUserIdStmt.setString(1, partnerUsername);
            ResultSet userIdRs = getUserIdStmt.executeQuery();
            if (userIdRs.next()) {
                partnerUserID = userIdRs.getInt("userID");
            }
            userIdRs.close();
            getUserIdStmt.close();

            if (partnerUserID != -1 && partnerUserID != currentUserID) {
                String findChatSQL = "SELECT chatID FROM chat WHERE (chatter1UserID = ? AND chatter2UserID = ?) OR (chatter1UserID = ? AND chatter2UserID = ?)";
                PreparedStatement findChatStmt = conn.prepareStatement(findChatSQL);
                findChatStmt.setInt(1, currentUserID);
                findChatStmt.setInt(2, partnerUserID);
                findChatStmt.setInt(3, partnerUserID);
                findChatStmt.setInt(4, currentUserID);
                ResultSet chatRs = findChatStmt.executeQuery();
                if (chatRs.next()) {
                    chatID = chatRs.getInt("chatID");
                } else {
                    String createChatSQL = "INSERT INTO chat (chatter1UserID, chatter2UserID) VALUES (?, ?)";
                    PreparedStatement createChatStmt = conn.prepareStatement(createChatSQL, Statement.RETURN_GENERATED_KEYS);
                    createChatStmt.setInt(1, currentUserID);
                    createChatStmt.setInt(2, partnerUserID);
                    createChatStmt.executeUpdate();
                    ResultSet keysRs = createChatStmt.getGeneratedKeys();
                    if (keysRs.next()) {
                        chatID = keysRs.getInt(1);
                    }
                    keysRs.close();
                    createChatStmt.close();
                }
                chatRs.close();
                findChatStmt.close();
            } else if (partnerUserID == currentUserID) {
                out.println("<p>You cannot start a chat with yourself.</p>");
            } else {
                out.println("<p>User not found.</p>");
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }

    // Handling message sending from the form submission
    String messageToSend = request.getParameter("message");
    if (messageToSend != null && !messageToSend.trim().isEmpty() && chatID != -1 && currentUserID != null) {
        try {
            conn = new ApplicationDB().getConnection();
            String insertMessageSQL = "INSERT INTO messages (chatID, senderUserID, message) VALUES (?, ?, ?)";
            PreparedStatement insertMessageStmt = conn.prepareStatement(insertMessageSQL);
            insertMessageStmt.setInt(1, chatID);
            insertMessageStmt.setInt(2, currentUserID);
            insertMessageStmt.setString(3, messageToSend);
            insertMessageStmt.executeUpdate();
            insertMessageStmt.close();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Chat Room</title>
    <meta http-equiv="refresh" content="5">
    <style>
        .message-box { border: 1px solid #ddd; margin: 20px; padding: 10px; height: 300px; overflow-y: auto; }
        .message { margin-bottom: 10px; padding: 5px; border-bottom: 1px solid #f0f0f0; }
        .message span.username { font-weight: bold; }
        .message span.timestamp { font-size: 0.8em; color: #666; }
        form { margin-top: 20px; }
        .exit-chat { margin-top: 20px; }
    </style>
</head>
<body>
    <h1>Chat Room</h1>
    <% if (chatID != -1) { %>
        <div class="message-box">
            <% 
            try {
                conn = new ApplicationDB().getConnection();
                String getMessagesSQL = "SELECT m.message, m.timestamp, u.username FROM messages m INNER JOIN users u ON m.senderUserID = u.userID WHERE chatID = ? ORDER BY m.timestamp ASC";
                PreparedStatement getMessagesStmt = conn.prepareStatement(getMessagesSQL);
                getMessagesStmt.setInt(1, chatID);
                ResultSet messagesRs = getMessagesStmt.executeQuery();
                while (messagesRs.next()) {
                    String username = messagesRs.getString("username");
                    String message = messagesRs.getString("message");
                    Timestamp timestamp = messagesRs.getTimestamp("timestamp");
                    out.println("<div class='message'><span class='username'>" + username + ":</span> " + message + " <span class='timestamp'>[" + timestamp + "]</span></div>");
                }
                messagesRs.close();
                getMessagesStmt.close();
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                if (conn != null) try { conn.close(); } catch (Exception e) {}
            }
            %>
        </div>
        <form action="chatRoom.jsp?partnerUsername=<%= partnerUsername %>" method="post">
            <input type="hidden" name="chatID" value="<%= chatID %>">
            <label for="message">Message:</label>
            <input type="text" id="message" name="message" required>
            <input type="submit" value="Send">
        </form>
    <% } else { %>
        <form action="chatRoom.jsp" method="get">
            <label for="partnerUsername">Enter Partner's Username:</label>
            <input type="text" id="partnerUsername" name="partnerUsername" required>
            <input type="submit" value="Start Chat">
        </form>
    <% } %>
    <div class="exit-chat">
        <button onclick="window.location.href='dashboard.jsp';">Exit Chat</button>
    </div>
</body>
</html>
