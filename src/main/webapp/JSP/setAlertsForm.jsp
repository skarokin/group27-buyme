<!DOCTYPE html>
<html>
<head>
    <title>Set Alerts</title>
</head>
<body>
    <h1>Set an Alert for an Item</h1>
    <form action="<%=request.getContextPath()%>/JSP/setAlerts.jsp" method="post">
        Make: <input type="text" name="make"><br>
        Model: <input type="text" name="model"><br>
        Year: <input type="number" name="yom"><br>
        Color: <input type="text" name="color"><br>
        <button type="submit">Set Alert</button>
    </form>
    <a href="<%=request.getContextPath()%>/JSP/dashboard.jsp">Back to Dashboard</a>
</body>
</html>
