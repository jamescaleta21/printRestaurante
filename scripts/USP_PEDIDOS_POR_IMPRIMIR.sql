IF EXISTS
(
    SELECT TOP 1
        s.SPECIFIC_NAME
    FROM INFORMATION_SCHEMA.ROUTINES s
    WHERE s.ROUTINE_TYPE = 'PROCEDURE'
          AND s.ROUTINE_NAME = 'USP_PEDIDOS_POR_IMPRIMIR'
)
BEGIN
    DROP PROC [dbo].[USP_PEDIDOS_POR_IMPRIMIR];
END;
GO
/*
USP_PEDIDOS_POR_IMPRIMIR '01'
*/
CREATE PROCEDURE [dbo].[USP_PEDIDOS_POR_IMPRIMIR] @CODCIA CHAR(2)
WITH ENCRYPTION
AS
SET NOCOUNT ON;

DECLARE @IMPRESORA_PRECUENTA VARCHAR(100);

SELECT TOP 1
    @IMPRESORA_PRECUENTA = p.PAR_PRINT_CUENTA
FROM dbo.PARGEN p
WHERE p.PAR_CODCIA = @CODCIA;

SELECT wp.IDPRINT,
       wp.NUMSER,
       wp.NUMFAC,
       CONVERT(CHAR(8), wp.FECHA, 112) AS 'FECHA',
       wp.CODMESA,
       @IMPRESORA_PRECUENTA AS 'PRINT'
FROM dbo.W_PEDIDO wp
WHERE COALESCE(wp.PRECUENTA, 0) = 1
      AND wp.CODCIA = @CODCIA
ORDER BY wp.FECHAREG;
GO