<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="com.cs336.pkg.ApplicationDB" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Placeholder for user ID of the logged-in user
    Integer currentUserID = (Integer) session.getAttribute("userID"); // Assume the user ID is stored in the session after login
    String partnerUsername = request.getParameter("partnerUsername"); // The username of the chat partner, entered by the user in the form below
    int chatID = -1;
%>
<!DOCTYPE html>
<html>
<head>
    <title>Chat Room</title>
    <style>
        /* Add CSS styles */
        .message-box {
            border: 1px solid #ddd;
            margin: 20px;
            padding: 10px;
            height: 300px;
            overflow-y: auto;
        }
        .message {
            margin-bottom: 10px;
            padding: 5px;
            border-bottom: 1px solid #f0f0f0;
        }
        form {
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <h1>Chat Room</h1>
    <!-- Form for starting chat with a partner based on username -->
    <form action="startChat.jsp" method="post">
        <label for="partnerUsername">Enter Partner's Username:</label>
        <input type="text" id="partnerUsername" name="partnerUsername" required>
        <input type="submit" value="Start Chat">
    </form>
    <% 
        // Start the chat if the partnerUsername is not null
        if (partnerUsername != null && !partnerUsername.trim().isEmpty()) {
            try (Connection conn = new ApplicationDB().getConnection()) {
                // Get the userID of the partner
                int partnerUserID = -1;
                String getUserIdSQL = "SELECT userID FROM users WHERE username = ?";
                try (PreparedStatement getUserIdStmt = conn.prepareStatement(getUserIdSQL)) {
                    getUserIdStmt.setString(1, partnerUsername);
                    ResultSet userIdRs = getUserIdStmt.executeQuery();
                    if (userIdRs.next()) {
                        partnerUserID = userIdRs.getInt("userID");
                    }
                }

                // Proceed if we found the partner's userID
                if (partnerUserID != -1) {
                    // Find or create a chat session
                    String findChatSQL = "SELECT chatID FROM chat WHERE (chatter1UserID = ? AND chatter2UserID = ?) OR (chatter1UserID = ? AND chatter2UserID = ?)";
                    try (PreparedStatement findChatStmt = conn.prepareStatement(findChatSQL)) {
                        findChatStmt.setInt(1, currentUserID);
                        findChatStmt.setInt(2, partnerUserID);
                        findChatStmt.setInt(3, partnerUserID);
                        findChatStmt.setInt(4, currentUserID);
                        ResultSet chatRs = findChatStmt.executeQuery();
                        if (chatRs.next()) {
                            chatID = chatRs.getInt("chatID");
                        } else {
                            String createChatSQL = "INSERT INTO chat (chatter1UserID, chatter2UserID) VALUES (?, ?)";
                            try (PreparedStatement createChatStmt = conn.prepareStatement(createChatSQL, Statement.RETURN_GENERATED_KEYS)) {
                                createChatStmt.setInt(1, currentUserID);
                                createChatStmt.setInt(2, partnerUserID);
                                createChatStmt.executeUpdate();
                                ResultSet keysRs = createChatStmt.getGeneratedKeys();
                                if (keysRs.next()) {
                                    chatID = keysRs.getInt(1);
                                }
                            }
                        }
                    }

                    // Fetch the messages for this chat
                    if (chatID != -1) {
                        List<String> messages = new ArrayList<>();
                        String getMessagesSQL = "SELECT * FROM messages WHERE chatID = ? ORDER BY timestamp ASC";
                        try (PreparedStatement getMessagesStmt = conn.prepareStatement(getMessagesSQL)) {
                            getMessagesStmt.setInt(1, chatID);
                            ResultSet messagesRs = getMessagesStmt.executeQuery();
                            while (messagesRs.next()) {
                                String message = messagesRs.getString("message");
                                messages.add(message);
                            }
                        }
                        // Display the messages
                        for (String message : messages) {
                            out.println("<div class='message'>" + message + "</div>");
                        }
                    }
                } else {
                    out.println("<p>User not found.</p>");
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    %>
    <% if (chatID != -1) { %>
        <!-- Form for sending messages -->
        <form action="sendMessage.jsp" method="post">
            <input type="hidden" name="chatID" value="<%= chatID %>">
            <input type="text" name="message" required>
            <input type="submit" value="Send">
        </form>
    <% } %>
</body>
</html>
