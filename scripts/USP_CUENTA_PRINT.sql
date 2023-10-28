IF EXISTS ( SELECT TOP 1
                    S.SPECIFIC_NAME
            FROM    information_schema.routines s
            WHERE   s.ROUTINE_TYPE = 'PROCEDURE'
                    AND S.ROUTINE_NAME = 'USP_CUENTA_PRINT' )
    BEGIN
        DROP PROC [dbo].[USP_CUENTA_PRINT]
    END
GO
/*

*/
--exec SpPrintComanda2 '01','100',20141,'35,27,','0,1,',1,' '

CREATE PROCEDURE [dbo].[USP_CUENTA_PRINT]
    @CodCia CHAR(2) ,
    @NumSer CHAR(3) ,
    @NumFac INT ,
    @xdet VARCHAR(4000) = NULL ,
    @xnumsec VARCHAR(4000) = NULL ,
    @precuenta BIT = NULL ,
    @CTA CHAR(1) = NULL
--With Encryption
AS
    SET NOCOUNT ON
    DECLARE @tbltmp TABLE ( cp INT )
    DECLARE @idoc INT

	IF LEN(RTRIM(LTRIM(@xdet))) = 0
	BEGIN
	    SET @xdet = null
	END

	IF LEN(RTRIM(LTRIM(@xnumsec))) = 0
	BEGIN
	    SET @xnumsec=null
	END

--productos en general
    DECLARE @tbldata TABLE
        (
          PED_FECHA DATETIME ,
          NROCOMANDA VARCHAR(10) ,
          PED_CANTIDAD MONEY ,
          PED_PRECIO MONEY ,
          PED_IGV MONEY ,
          PED_BRUTO MONEY ,
          PED_HORA VARCHAR(15) ,
          PED_MONEDA CHAR(1) ,
          PED_SUBTOTAL MONEY ,
          ART_NOMBRE VARCHAR(80) ,
          CLI_NOMBRE VARCHAR(80) ,
          VEM_NOMBRE VARCHAR(60) ,
          PED_OFERTA VARCHAR(300) ,
          PED_CLIENTE VARCHAR(120) ,
          ped_familia INT ,
          codprod BIGINT ,
          flag CHAR(1) ,
          actual DATETIME ,
          FAMILIA VARCHAR(100) ,
          CARACTERISTICAS VARCHAR(4000)
        )

    DECLARE @fecha DATETIME ,
        @nrocomanda VARCHAR(15) ,
        @moneda CHAR(1) ,
        @mesa VARCHAR(50) ,
        @mozo VARCHAR(40)
	--PARCHE ICBPER
	
	DECLARE @ICBPER DECIMAL(8,2)
    
    SELECT TOP 1 @ICBPER = COALESCE(G.GEN_ICBPER,0) FROM dbo.GENERAL g
	--FIN PARCHE
	
             DECLARE @TBLICBPER TABLE
                (
                  CODART BIGINT ,
                  ICBPER MONEY
                )
    

    IF @PreCuenta IS NULL
        BEGIN
            IF @xdet IS  NULL
                BEGIN
                    INSERT  INTO @tbldata
                            SELECT  PEDIDOS.PED_FECHA ,
                                    PEDIDOS.PED_NUMSER + '-'
                                    + RTRIM(LTRIM(STR(PEDIDOS.PED_NUMFAC))) AS 'NROCOMANDA' ,
                                    PEDIDOS.PED_CANTIDAD ,
                                    PEDIDOS.PED_PRECIO ,
                                    PEDIDOS.PED_IGV ,
                                    PEDIDOS.PED_BRUTO ,
                                    PEDIDOS.PED_HORA ,
                                    PEDIDOS.PED_MONEDA ,
                                    PEDIDOS.PED_SUBTOTAL ,
                                    ARTI.ART_NOMBRE ,
                                    RTRIM(LTRIM(CLIENTES.MES_DESCRIP)) + ' - '
                                    + dbo.FnDevuelveZona(@CodCia,
                                                         clientes.mes_codzon) AS CLI_NOMBRE ,
                                    VEMAEST.VEM_NOMBRE ,
                                    PEDIDOS.PED_OFERTA ,
                                    pedidos.PED_CLIENTE ,
                                    pedidos.ped_familia2 AS 'PED_FAMILIA' ,
                                    arti.art_key ,
                                    arti.art_flag_stock ,
                                    GETDATE() ,
                                    ( SELECT    RTRIM(LTRIM(T.TAB_NOMLARGO))
                                      FROM      dbo.TABLAS t
                                      WHERE     T.TAB_TIPREG = 122
                                                AND T.TAB_CODCIA = @CodCia
                                                AND T.TAB_NUMTAB = pedidos.ped_familia2
                                    ) ,
                                    DBO.FnDevuelveCaracteristica(PEDIDOS.PED_CODCIA,
                                                              PEDIDOS.PED_FECHA,
                                                              PEDIDOS.PED_NUMFAC,
                                                              PEDIDOS.PED_NUMSER,
                                                              PEDIDOS.PED_NUMSEC,
                                                              PEDIDOS.PED_CODART)
                            FROM    dbo.PEDIDOS PEDIDOS
                                    INNER JOIN dbo.MESAS CLIENTES ON PEDIDOS.PED_CODCLIE = CLIENTES.MES_CODMES
                                            AND PEDIDOS.PED_CODCIA = CLIENTES.MES_CODCIA
                                    INNER JOIN dbo.VEMAEST VEMAEST ON PEDIDOS.PED_CODVEN = VEMAEST.VEM_CODVEN
                                                              AND PEDIDOS.PED_CODCIA = VEMAEST.VEM_CODCIA
                                    INNER JOIN dbo.ARTI ARTI ON PEDIDOS.PED_CODART = ARTI.ART_KEY
                                                              AND PEDIDOS.PED_CODCIA = ARTI.ART_CODCIA
                            WHERE   PEDIDOS.PED_NUMSER = @NumSer
                                    AND PEDIDOS.PED_NUMFAC = @NumFac
                                    AND PEDIDOS.PED_CODCIA = @CodCia
 
                END
            ELSE
                BEGIN
              
                    INSERT  INTO @tbldata
                            SELECT  PEDIDOS.PED_FECHA ,
                                    PEDIDOS.PED_NUMSER + '-'
                                    + RTRIM(LTRIM(STR(PEDIDOS.PED_NUMFAC))) AS 'NROCOMANDA' ,
                                    PEDIDOS.PED_CANTIDAD ,
                                    PEDIDOS.PED_PRECIO ,
                                    PEDIDOS.PED_IGV ,
                                    PEDIDOS.PED_BRUTO ,
                                    PEDIDOS.PED_HORA ,
                                    PEDIDOS.PED_MONEDA ,
                                    PEDIDOS.PED_SUBTOTAL ,
                                    ARTI.ART_NOMBRE ,
                                    RTRIM(LTRIM(CLIENTES.MES_DESCRIP)) + ' - '
                                    + dbo.FnDevuelveZona(@CodCia,
                                                         clientes.mes_codzon) AS CLI_NOMBRE ,
                                    VEMAEST.VEM_NOMBRE ,
                                    PEDIDOS.PED_OFERTA ,
                                    pedidos.PED_CLIENTE ,
                                    pedidos.ped_familia2 AS 'PED_FAMILIA' ,
                                    arti.art_key ,
                                    arti.art_flag_stock ,
                                    GETDATE() ,
                                    ( SELECT    RTRIM(LTRIM(T.TAB_NOMLARGO))
                                      FROM      dbo.TABLAS t
                                      WHERE     T.TAB_TIPREG = 122
                                                AND T.TAB_CODCIA = @CodCia
                                                AND T.TAB_NUMTAB = pedidos.ped_familia2
                                    ) ,
                                    DBO.FnDevuelveCaracteristica(PEDIDOS.PED_CODCIA,
                                                              PEDIDOS.PED_FECHA,
                                                              PEDIDOS.PED_NUMFAC,
                                                              PEDIDOS.PED_NUMSER,
                                                              PEDIDOS.PED_NUMSEC,
                                                              PEDIDOS.PED_CODART)
                            FROM    dbo.PEDIDOS PEDIDOS
                                    INNER JOIN dbo.MESAS CLIENTES ON PEDIDOS.PED_CODCLIE = CLIENTES.MES_CODMES
                                                              AND PEDIDOS.PED_CODCIA = CLIENTES.MES_CODCIA
                                    INNER JOIN dbo.VEMAEST VEMAEST ON PEDIDOS.PED_CODVEN = VEMAEST.VEM_CODVEN
                                                              AND PEDIDOS.PED_CODCIA = VEMAEST.VEM_CODCIA
                                    INNER JOIN dbo.ARTI ARTI ON PEDIDOS.PED_CODART = ARTI.ART_KEY
                                                              AND PEDIDOS.PED_CODCIA = ARTI.ART_CODCIA
                            WHERE   PEDIDOS.PED_NUMSER = @NumSer
                                    AND PEDIDOS.PED_NUMFAC = @NumFac
                                    AND PEDIDOS.PED_CODCIA = @CodCia
                      AND pedidos.ped_codart IN (
                                    SELECT  parametro
                                    FROM    dbo.FnTextoaTabla(@xdet) )
                                    AND pedidos.ped_numsec IN (
                                    SELECT  parametro
                                    FROM    dbo.FnTextoaTabla(@xnumsec) )
                            ORDER BY PEDIDOS.PED_FECHAREG

--SELECT * FROM @tbldata
 /*
exec SpPrintComanda2 '01','100',29,'208,','0,'
exec SpPrintComanda2 '01','100',29,'208,21,','0,1,'
*/
 
 
--obtengo datos para impresion
                    SELECT  @fecha = PEDIDOS.PED_FECHA ,
                            @nrocomanda = PEDIDOS.PED_NUMSER + '-'
                            + RTRIM(LTRIM(STR(PEDIDOS.PED_NUMFAC))) ,
                            @moneda = PEDIDOS.PED_MONEDA ,
                            @mesa = RTRIM(LTRIM(CLIENTES.MES_DESCRIP)) + ' - '
                            + dbo.FnDevuelveZona(@CodCia, clientes.mes_codzon) ,
                            @mozo = VEMAEST.VEM_NOMBRE
                    FROM    dbo.PEDIDOS PEDIDOS
                            INNER JOIN dbo.MESAS CLIENTES ON PEDIDOS.PED_CODCLIE = CLIENTES.MES_CODMES
                                                             AND PEDIDOS.PED_CODCIA = CLIENTES.MES_CODCIA
                            INNER JOIN dbo.VEMAEST VEMAEST ON PEDIDOS.PED_CODVEN = VEMAEST.VEM_CODVEN
                                                              AND PEDIDOS.PED_CODCIA = VEMAEST.VEM_CODCIA
                            INNER JOIN dbo.ARTI ARTI ON PEDIDOS.PED_CODART = ARTI.ART_KEY
                                                        AND PEDIDOS.PED_CODCIA = ARTI.ART_CODCIA
                    WHERE   PEDIDOS.PED_NUMSER = @NumSer
                            AND PEDIDOS.PED_NUMFAC = @NumFac
                            AND PEDIDOS.PED_CODCIA = @CodCia
                            AND pedidos.ped_codart IN (
                            SELECT  parametro
                            FROM    dbo.FnTextoaTabla(@xdet) )
                            AND pedidos.ped_numsec IN (
                            SELECT  parametro
                            FROM    dbo.FnTextoaTabla(@xnumsec) )
 

                END

--actualizo los pedidos de acuerdo a impresion
            UPDATE  pedidos
            SET     ped_aprobado = '1'
            WHERE   pedidos.ped_codart IN ( SELECT  parametro
                                            FROM    dbo.FnTextoaTabla(@xdet) )
                    AND pedidos.ped_numsec IN (
                    SELECT  parametro
                    FROM    dbo.FnTextoaTabla(@xnumsec) )


--Select * from @tbldata
--tabla para los productos que son combos
            DECLARE @tblcombos TABLE
                (
                  codcombo BIGINT ,
                  cant BIGINT ,
                  sec TINYINT IDENTITY(1, 1) ,
                  hora VARCHAR(15)
                )

            INSERT  INTO @tblcombos
                    SELECT  codprod ,
                            ped_cantidad ,
                            ped_hora
                    FROM    @tbldata
                    WHERE   flag = 'C'


--SELECT * FROM @tblcombos
            DECLARE @hora VARCHAR(15)

            IF EXISTS ( SELECT TOP 1
                                codcombo
                        FROM    @tblcombos )
                BEGIN --ENTRA AQUI ES PORQUE TIENE COMBOS

                    DECLARE @tbltmpCombos TABLE
                        (
                          PED_FECHA DATETIME ,
                          NROCOMANDA VARCHAR(10) ,
                          PED_CANTIDAD MONEY ,
                          PED_PRECIO MONEY ,
                          PED_IGV MONEY ,
                          PED_BRUTO MONEY ,
                          PED_HORA VARCHAR(15) ,
                          PED_MONEDA CHAR(1) ,
                          PED_SUBTOTAL MONEY ,
                          ART_NOMBRE VARCHAR(80) ,
                          CLI_NOMBRE VARCHAR(80) ,
                          VEM_NOMBRE VARCHAR(60) ,
                          ped_oferta VARCHAR(300) ,
                          ped_cliente VARCHAR(120) ,
                          ped_familia2 INT ,
                          codprod BIGINT ,
                          flag CHAR(1) ,
                          FAMILIA VARCHAR(100) ,
                          num TINYINT IDENTITY
                        )
 
                    INSERT  INTO @tbltmpCombos
                            SELECT  PED_FECHA ,
                                    NROCOMANDA ,
                                    PED_CANTIDAD ,
                                    PED_PRECIO ,
                                    PED_IGV ,
                                    PED_BRUTO ,
                                    PED_HORA ,
                                    PED_MONEDA ,
                                    PED_SUBTOTAL ,
                                    ART_NOMBRE ,
                                    CLI_NOMBRE ,
                                    VEM_NOMBRE ,
                                    ped_oferta ,
                                    ped_cliente ,
                                    ped_familia ,
                                    codprod ,
                                    flag ,
                                    FAMILIA
                            FROM    @tbldata
                            WHERE   flag = 'C'
 
                    DELETE  FROM @tbldata
                    WHERE   flag = 'C'
 
--select * from @tbldata
--Select * from @tbltmpCombos
/*

exec SpPrintComanda2 '01','100',29,'208,','0,'
exec SpPrintComanda2 '01','100',29,'208,21,','0,1,'

*/
--SpPrintComanda2 '01','100',680,'74185,74185,','0,1,'
 
                    DECLARE @codcombo BIGINT ,
                        @cant BIGINT ,
                        @num TINYINT ,
                        @po VARCHAR(300)
--aqui entra el cursor
                    DECLARE cCombos CURSOR
                    FOR
                        SELECT  codcombo ,
                                cant ,
                                sec ,
                                hora
                        FROM    @tblcombos
 
                    OPEN cCombos
 
                    FETCH cCombos INTO @codcombo, @cant, @num, @hora
 
                    WHILE ( @@Fetch_Status = 0 )
                        BEGIN
 
                            INSERT  INTO @tbldata
                                    SELECT  PED_FECHA ,
                                            NROCOMANDA ,
                                            PED_CANTIDAD ,
                                            PED_PRECIO ,
                                            PED_IGV ,
                                            PED_BRUTO ,
                                            PED_HORA ,
                                            PED_MONEDA ,
                                            PED_SUBTOTAL ,
                                            ART_NOMBRE ,
                                            CLI_NOMBRE ,
                                            VEM_NOMBRE ,
                                            PED_OFERTA ,
                                            ped_cliente ,
                                            ped_familia2 ,
                                            codprod ,
                                            flag ,
                                            GETDATE() ,
                                            FAMILIA ,
                                            ''
                                    FROM    @tbltmpCombos
                                    WHERE   codprod = @codcombo
                                            AND num = @num
 

                            INSERT  INTO @tbldata
SELECT  @fecha ,
                                            @nrocomanda ,
                                            0,--pa.PA_PROM * @cant , --ped_cantidad
                                            0 ,
                                            0 ,
                                            0 ,
                                            @hora ,
                                            @moneda ,
                                            0 ,
                                            '   ' + ar.art_nombre ,
                                            @mesa ,
                                            @mozo ,
                                            ISNULL(@po, '') ,
                                            '' ,
                                            ar.art_familia ,
                                            pa.PA_CODART ,
                                            ar.art_flag_stock ,
                                            GETDATE() ,
                                            ( SELECT    RTRIM(LTRIM(T.TAB_NOMLARGO))
                                              FROM      dbo.TABLAS t
                                              WHERE     T.TAB_TIPREG = 122
                                                        AND T.TAB_CODCIA = @CodCia
                                                        AND T.TAB_NUMTAB = AR.ART_FAMILIA
                                            ) ,
                                            ''
                                    FROM    paquetes pa
                                            INNER JOIN arti ar ON pa.pa_codcia = ar.art_codcia
                                                              AND pa_codart = ar.art_key
                                    WHERE   pa.pa_codpa = @codcombo
                                            AND pa.pa_codcia = @codcia

                            FETCH cCombos INTO @codcombo, @cant, @num, @hora
                        END
 
                    CLOSE cCombos
                    DEALLOCATE cCombos
 
 
                END
                
                
                --PARCHE PARA AGREGAR FAMILIA AL COMBO FALTANTE
            DECLARE @MIN INT ,
                @MAX INT
            DECLARE @TBLFAMILIA TABLE
                (
                  IDFAMILIA INT ,
                  INDICE INT IDENTITY
                )
            INSERT  INTO @TBLFAMILIA
                    ( IDFAMILIA
                    )
                    SELECT DISTINCT
                            PED_FAMILIA
                    FROM    @TBLDATA
              
            SELECT  @MIN = MIN(T.INDICE)
            FROM    @TBLFAMILIA t
            SELECT  @MAX = MAX(T.INDICE)
            FROM    @TBLFAMILIA t
 
            WHILE @MIN <= @MAX
                BEGIN
                    IF NOT EXISTS ( SELECT TOP 1
                                            NROCOMANDA
                                    FROM    @TBLDATA
                                    WHERE   PED_FAMILIA = ( SELECT TOP 1
                                                              T.IDFAMILIA
                                                            FROM
                                                              @TBLFAMILIA t
                                                            WHERE
                                                              T.INDICE = @MIN
                                                          )
                                            AND flag = 'C' )
                        BEGIN
                        --SELECT 'noexiste'
        
                            INSERT  INTO @TBLDATA
                                    SELECT  PED_FECHA ,
                                            NROCOMANDA ,
                                            PED_CANTIDAD ,
                                            PED_PRECIO ,
                                            PED_IGV ,
                                      PED_BRUTO ,
                                            dbo.FnDevuelveHora(GETDATE()) ,
                                            PED_MONEDA ,
                                            PED_SUBTOTAL ,
                                            ART_NOMBRE ,
                                            CLI_NOMBRE ,
                                            VEM_NOMBRE ,
                                            PED_OFERTA ,
                                            ped_cliente ,
                                            ( SELECT TOP 1
                                                        T.IDFAMILIA
                                              FROM      @TBLFAMILIA t
                                              WHERE     T.INDICE = @MIN
                                            ) ,
                                            codprod ,
                                            'C' ,
                                            actual ,
                                            ( SELECT TOP 1
                                                        t.tab_nomlargo
                                              FROM      dbo.TABLAS t
                                              WHERE     t.TAB_TIPREG = 122
                                                        AND t.TAB_NUMTAB = ( SELECT TOP 1
                                                              T.IDFAMILIA
                                                              FROM
                                                              @TBLFAMILIA t
                                                              WHERE
                                                              T.INDICE = @MIN
                                                              )
                                            ) ,
                                            ''
                                    FROM    @TBLDATA
                                    WHERE   PED_FAMILIA = ( SELECT TOP 1
                                                              t.ped_familia
                                                            FROM
                                                              @tbldata t
                                                            WHERE
                                                              T.flag = 'C'
                                                          )
                                            AND flag = 'C'
		
		 
                        END
	
	
                    SET @MIN = @MIN + 1
                END
                
 
            SELECT  *
            FROM    @tbldata
            ORDER BY ped_familia ,
                    flag ,
                    ped_hora

        END
    ELSE
        BEGIN
        
        SELECT TOP 1 @FECHA = PED_FECHA FROM PEDIDOS WHERE PED_CODCIA = @CodCia AND PED_NUMSER = @NumSer AND PED_NUMFAC= @NumFac
        
          INSERT  INTO @TBLICBPER
                    ( CODART ,
                      ICBPER
                    )
                    SELECT  p.PA_CODPA ,
                           SUM( p.PA_PROM*@ICBPER)
                    FROM    dbo.PAQUETES p
                            INNER JOIN dbo.ARTI art ON P.PA_CODCIA = art.ART_CODCIA
                                                       AND P.PA_CODART = art.art_key
                    WHERE   PA_CODPA IN (
                            SELECT  A2.ART_KEY
                            FROM    pedidos p
                                    INNER JOIN dbo.ARTI a2 ON p.PED_CODCIA = a2.ART_CODCIA
                                                              AND p.PED_CODART = a2.ART_KEY
                                    INNER JOIN ALLOG A ON p.PED_TRANSP = a.ALL_NUMOPER
                                                          AND A.ALL_CODCIA = @CODCIA
                                                          AND A.ALL_FECHA_DIA = @FECHA
                                                          AND A.ALL_FLAG_EXT = 'N'
                            WHERE  
                                    ped_codcia = @CodCia
                                    AND ped_fecha = @Fecha
                                    AND ped_estado = 'N'
                                    AND ped_situacion <> 'A'
                                    AND ped_fac <> ped_Cantidad
                                    AND ped_numfac = @NUMFAC
                                    AND a2.ART_FLAG_STOCK = 'C' )
                            AND art.ART_CALIDAD = 0 GROUP BY p.PA_CODPA
    
        
declare @total money
declare @cant2 int



select @total = sum(PED_SUBTOTAL) from PEDIDOS where PED_NUMFAC=@NUMFAC

--exec SpPrintComanda2 '01','100',20141,'35,27,','0,1,',1,' '
--SELECT * FROM PEDIDOS WHERE PED_NUMFAC=20141
--SELECT * FROM @TBLICBPER


select @ICBPER = icbper from @TBLICBPER
select @cant2 = sum(ped_cantidad) from PEDIDOS where PED_NUMFAC=  @NUMFAC  and PED_CODART in (select codart from @TBLICBPER)

set @total = @total + (@ICBPER * @cant2)

--entra aqui cuando es precuenta
            IF @xdet IS NULL
                BEGIN
                    SELECT  PEDIDOS.PED_FECHA ,
                            PEDIDOS.PED_NUMSER + '-'
                            + RTRIM(LTRIM(STR(PEDIDOS.PED_NUMFAC))) AS 'NROCOMANDA' ,
                            --PEDIDOS.PED_CANTIDAD ,
                            CASE WHEN CANTIDAD_DELIVERY IS NULL
                                 THEN PEDIDOS.PED_CANTIDAD
                                 ELSE PEDIDOS.CANTIDAD_DELIVERY
                            END AS 'PED_CANTIDAD' ,
                            PEDIDOS.PED_PRECIO ,
                            PEDIDOS.PED_IGV ,
                            PEDIDOS.PED_BRUTO ,
                            PEDIDOS.PED_HORA ,
                            PEDIDOS.PED_MONEDA ,
                             (case WHEN (SELECT COALESCE(XA.ART_CALIDAD,1) FROM dbo.ARTI xa WHERE XA.ART_CODCIA = @CODCIA AND XA.ART_KEY = pedidos.PED_CODART) = 0 then (CASE WHEN CANTIDAD_DELIVERY IS NULL
                                 THEN PEDIDOS.PED_CANTIDAD
                                 ELSE PEDIDOS.CANTIDAD_DELIVERY
                  END * @ICBPER) else 0 END) + PEDIDOS.PED_SUBTOTAL  + coalesce(t.ICBPER,0) AS 'PED_SUBTOTAL',
                            CASE WHEN PEDIDOS.CANTIDAD_DELIVERY IS NOT NULL
                                 THEN '1/2  '
                                 ELSE ''
                            END + ARTI.ART_NOMBRE AS 'ART_NOMBRE' ,
                            RTRIM(LTRIM(CLIENTES.MES_DESCRIP)) + ' - '
                            + dbo.FnDevuelveZona(@CodCia, clientes.mes_codzon) AS CLI_NOMBRE ,
                            --VEMAEST.VEM_NOMBRE ,
                            VEMAEST.VEM_NOMBRE ,
                            pedidos.ped_cta ,
                            pedidos.ped_familia2 AS 'PED_FAMILIA',
                            @total AS 'TOTAL'
                    FROM    dbo.PEDIDOS PEDIDOS
                            INNER JOIN dbo.MESAS CLIENTES ON PEDIDOS.PED_CODCLIE = CLIENTES.MES_CODMES
                                                             AND PEDIDOS.PED_CODCIA = CLIENTES.MES_CODCIA
                            INNER JOIN dbo.PEDIDOS_CABECERA pc ON PEDIDOS.PED_CODCIA = PC.CODCIA
                                                              AND PEDIDOS.PED_NUMFAC = PC.NUMFAC
                                                              AND PEDIDOS.PED_NUMSER = PC.NUMSER
                                                              AND PEDIDOS.PED_FECHA = PC.FECHA
                            INNER JOIN dbo.VEMAEST VEMAEST ON PC.CODMOZO = VEMAEST.VEM_CODVEN
                                                              AND PC.CODCIA = VEMAEST.VEM_CODCIA
                            INNER JOIN dbo.ARTI ARTI ON PEDIDOS.PED_CODART = ARTI.ART_KEY
                                                        AND PEDIDOS.PED_CODCIA = ARTI.ART_CODCIA
                                                         left join @TBLICBPER t on PEDIDOS.PED_CODART = t.CODART
                    WHERE   PEDIDOS.PED_NUMSER = @NumSer
                            AND PEDIDOS.PED_NUMFAC = @NumFac
                            AND PEDIDOS.PED_CODCIA = @CodCia
                            AND ISNULL(PEDIDOS.PED_CTA, '') = @CTA
                    ORDER BY PED_NUMSEC --CAMBIADO
                END
            ELSE
                BEGIN
 
                    SELECT  PEDIDOS.PED_FECHA ,
                            PEDIDOS.PED_NUMSER + '-'
                            + RTRIM(LTRIM(STR(PEDIDOS.PED_NUMFAC))) AS 'NROCOMANDA' ,
                            CASE WHEN CANTIDAD_DELIVERY IS NULL
                                 THEN PEDIDOS.PED_CANTIDAD
                                 ELSE PEDIDOS.CANTIDAD_DELIVERY
                            END AS 'PED_CANTIDAD' ,
                            PEDIDOS.PED_PRECIO ,
                            PEDIDOS.PED_IGV ,
                            PEDIDOS.PED_BRUTO ,
                            PEDIDOS.PED_HORA ,
                            PEDIDOS.PED_MONEDA ,
                            (case WHEN (SELECT COALESCE(XA.ART_CALIDAD,1) FROM dbo.ARTI xa WHERE XA.ART_CODCIA = @CODCIA AND XA.ART_KEY = pedidos.PED_CODART) = 0 then (CASE WHEN CANTIDAD_DELIVERY IS NULL
                                 THEN PEDIDOS.PED_CANTIDAD
                                 ELSE PEDIDOS.CANTIDAD_DELIVERY
                            END * @ICBPER) else 0 END) + PEDIDOS.PED_SUBTOTAL + coalesce(t.ICBPER,0) AS 'PED_SUBTOTAL',
                            --PEDIDOS.PED_SUBTOTAL ,
                            CASE WHEN PEDIDOS.CANTIDAD_DELIVERY IS NOT NULL
                                 THEN '1/2  '
                                 ELSE ''
                            END + ARTI.ART_NOMBRE AS 'ART_NOMBRE' ,
                            RTRIM(LTRIM(CLIENTES.MES_DESCRIP)) + ' - '
                            + dbo.FnDevuelveZona(@CodCia, clientes.mes_codzon) AS CLI_NOMBRE ,
                            VEMAEST.VEM_NOMBRE ,
                            pedidos.ped_cta ,
                            pedidos.ped_familia2 AS 'PED_FAMILIA' ,
                            DBO.FnDevuelveCaracteristica(PEDIDOS.PED_CODCIA,
                                                         PEDIDOS.PED_FECHA,
                                              PEDIDOS.PED_NUMFAC,
                                                         PEDIDOS.PED_NUMSER,
                                                         PEDIDOS.PED_NUMSEC,
                                                         PEDIDOS.PED_CODART) AS 'CARACTERISTICA'
						,@total AS 'TOTAL'
						--,coalesce(t.ICBPER,0)
						
                    FROM    dbo.PEDIDOS PEDIDOS
                            INNER JOIN dbo.MESAS CLIENTES ON PEDIDOS.PED_CODCLIE = CLIENTES.MES_CODMES
                                                             AND PEDIDOS.PED_CODCIA = CLIENTES.MES_CODCIA
                            INNER JOIN dbo.PEDIDOS_CABECERA pc ON PEDIDOS.PED_CODCIA = PC.CODCIA
                                                              AND PEDIDOS.PED_NUMFAC = PC.NUMFAC
                                                              AND PEDIDOS.PED_NUMSER = PC.NUMSER
                                                              AND PEDIDOS.PED_FECHA = PC.FECHA
                            INNER JOIN dbo.VEMAEST VEMAEST ON PC.CODMOZO = VEMAEST.VEM_CODVEN
                                                              AND PC.CODCIA = VEMAEST.VEM_CODCIA
                            INNER JOIN dbo.ARTI ARTI ON PEDIDOS.PED_CODART = ARTI.ART_KEY
                                                        AND PEDIDOS.PED_CODCIA = ARTI.ART_CODCIA
                                                        left join @TBLICBPER t on PEDIDOS.PED_CODART = t.CODART
                                                        /*
exec SpPrintComanda2 '01','100',46,'2050,','2,',1,' '
*/
                    WHERE   PEDIDOS.PED_NUMSER = @NumSer
                            AND PEDIDOS.PED_NUMFAC = @NumFac
                            AND PEDIDOS.PED_CODCIA = @CodCia
                            AND pedidos.ped_codart IN (
                            SELECT  parametro
                            FROM    dbo.FnTextoaTabla(@xdet) )
                            AND pedidos.ped_numsec IN (
                            SELECT  parametro
                            FROM    dbo.FnTextoaTabla(@xnumsec) )
                            AND ISNULL(PEDIDOS.PED_CTA, '') = @CTA
                    ORDER BY PED_NUMSEC --CAMBIADO
 
                END
        END


GO