DECLARE
  l_output NUMBER;
BEGIN
  FOR i IN 1..10 LOOP
    SELECT i
    INTO l_output
    FROM dual;
    DBMS_OUTPUT.PUT_LINE('Result: ' || l_output);
  END LOOP;
END;