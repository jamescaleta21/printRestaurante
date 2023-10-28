IF EXISTS ( SELECT TOP 1
                    S.SPECIFIC_NAME
            FROM    information_schema.routines s
            WHERE   s.ROUTINE_TYPE = 'PROCEDURE'
                    AND S.ROUTINE_NAME = 'WEB_COMANDA_DATOSIMPRESION' )
    BEGIN
        DROP PROC [dbo].[WEB_COMANDA_DATOSIMPRESION]
    END
GO
/*
WEB_COMANDA_DATOSIMPRESION '01'
exec SpPrintComanda2 '01','100',1,'1900,1861,2451,2469,','0,1,2,3,'
*/
CREATE PROCEDURE [dbo].[WEB_COMANDA_DATOSIMPRESION] @CODCIA CHAR(2)
AS --DECLARE @Exito VARCHAR(300)
    SET NOCOUNT ON 

    SELECT  * ,
            ( CASE WHEN EXISTS ( SELECT WPD.FECHA
                                 FROM   dbo.W_PEDIDO_DET wpd
                                        INNER JOIN dbo.PEDIDOS p ON WPD.CODCIA = P.PED_CODCIA
                                                              AND P.PED_NUMSER = WPD.NUMSER
                                                              AND WPD.NUMFAC = P.PED_NUMFAC
                                                              AND WPD.IDPRODUCTO = P.PED_CODART
                                                              AND WPD.NUMSEC = P.PED_NUMSEC
                                 WHERE  WPD.CODCIA = @CODCIA
                                        AND WPD.IDPRINT = WP.IDPRINT
                                        AND PED_APROBADO = '1' )
                   THEN 'DUPLICADO'
                   ELSE ''
              END ) AS 'MENSAJE'
    FROM    dbo.W_PEDIDO wp
    WHERE   WP.CODCIA = @CODCIA
	AND COALESCE(wp.PRECUENTA,0) = 0
    
    --SELECT DISTINCT
    --        WPD.IDFAMILIA ,
    --        WPD.IDPRINT ,
    --        T.IMPRESORA
    --FROM    dbo.W_PEDIDO_DET wpd
    --        INNER JOIN dbo.TABLAS t ON WPD.CODCIA = T.TAB_CODCIA
    --                                   AND WPD.IDFAMILIA = T.TAB_NUMTAB
    --WHERE   WPD.CODCIA = @CODCIA
    
   EXEC SP_FAMILIAS_LISTPRINT '01'

    SELECT  WPD.* ,
            P.PED_APROBADO AS 'APRO'
    FROM    dbo.W_PEDIDO_DET wpd
            INNER JOIN dbo.PEDIDOS p ON WPD.CODCIA = P.PED_CODCIA
                                        AND P.PED_NUMSER = WPD.NUMSER
                                        AND WPD.NUMFAC = P.PED_NUMFAC
                                        AND WPD.IDPRODUCTO = P.PED_CODART
                                        AND WPD.NUMSEC = P.PED_NUMSEC
    WHERE   WPD.CODCIA = @CODCIA


GO