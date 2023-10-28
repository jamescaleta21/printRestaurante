IF EXISTS ( SELECT TOP 1
                    S.SPECIFIC_NAME
            FROM    information_schema.routines s
            WHERE   s.ROUTINE_TYPE = 'PROCEDURE'
                    AND S.ROUTINE_NAME = 'USP_COMANDA_PRINT' )
    BEGIN
        DROP PROC [dbo].[USP_COMANDA_PRINT]
    END
GO
/*

*/
CREATE PROCEDURE [dbo].[USP_COMANDA_PRINT]
    @CODCIA CHAR(2),
    @FECHA DATE,
    @NUMSER CHAR(3),
    @NUMFAC BIGINT,
	@PRECUENTA BIT  = 0
	WITH ENCRYPTION
AS --DECLARE @Exito VARCHAR(300)
BEGIN
    SET NOCOUNT ON;
    DECLARE @MESSAGE VARCHAR(300),
            @CODE VARCHAR(10);

    SET @MESSAGE = 'Pedido enviado correctamente.';
    SET @CODE = '0';
    /*
	REALIZAR LAS VALIDACIONES RESPECTIVAS
*/

    DECLARE @IDPRINT BIGINT;
    BEGIN TRAN;
    BEGIN TRY

        SELECT TOP 1
               @IDPRINT = wp.IDPRINT + 1
        FROM dbo.W_PEDIDO wp
        ORDER BY wp.FECHAREG DESC;

        IF @IDPRINT IS NULL
        BEGIN
            SET @IDPRINT = 1;
        END;


        INSERT INTO dbo.W_PEDIDO
        (
            CODCIA,
            NUMSER,
            NUMFAC,
            FECHA,
            CODMESA,
            FECHAREG,
            IDPRINT,
			PRECUENTA
        )
        SELECT @CODCIA,
               @NUMSER,
               @NUMFAC,
               @FECHA,
               pc.CODMESA,
               GETDATE(),
               @IDPRINT,
			   @PRECUENTA
        FROM dbo.PEDIDOS_CABECERA pc
        WHERE pc.CODCIA = @CODCIA
              AND pc.NUMSER = @NUMSER
              AND pc.NUMFAC = @NUMFAC
              AND pc.FECHA = @FECHA;

        INSERT INTO dbo.W_PEDIDO_DET
        (
            CODCIA,
            NUMSER,
            NUMFAC,
            NUMSEC,
            FECHA,
            IDPRODUCTO,
            IDFAMILIA,
            CANTIDAD,
            IDPRINT
        )
        SELECT @CODCIA,
               @NUMSER,
               @NUMFAC,
               p.PED_NUMSEC,
               @FECHA,
               p.PED_CODART,
               p.PED_FAMILIA,
               p.PED_CANTIDAD,
               @IDPRINT
        FROM dbo.PEDIDOS p
        WHERE p.PED_CODCIA = @CODCIA
              AND p.PED_FECHA = @FECHA
              AND p.PED_ESTADO = 'N'
              AND p.PED_NUMSER = @NUMSER
              AND p.PED_NUMFAC = @NUMFAC
              AND p.PED_APROBADO <> '1';

    END TRY
    BEGIN CATCH
        SET @MESSAGE = ERROR_MESSAGE();
        SET @CODE = RTRIM(LTRIM(STR(ERROR_NUMBER())));
        ROLLBACK TRAN;
        GOTO Terminar;
    END CATCH;

    IF @@TRANCOUNT > 0
        COMMIT;

    Terminar:
    SELECT @CODE,
           @MESSAGE;
END;

GO