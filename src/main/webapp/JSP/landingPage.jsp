<!DOCTYPE html>
<html>
<head>
    <title>Success</title>
</head>
<body>
    <h2>BuyMe</h2>
    <form action="<%=request.getContextPath()%>/JSP/logout.jsp" method="post">
        <button type="submit">Logout</button>
    </form>

    <form action="<%=request.getContextPath()%>/JSP/delete.jsp" method="post">
        <button type="submit" onclick="return confirm('Are you sure you want to delete your account?');">Delete Account</button>
    </form>
</body>
</html>
