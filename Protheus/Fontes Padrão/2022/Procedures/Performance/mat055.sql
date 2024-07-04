Create Procedure MAT055_##
( 
 @IN_FILIALCOR    Char('B1_FILIAL'),
 @IN_MV_PAR03	  Char('B1_COD'),
 @IN_MV_PAR04	  Char('B1_COD'),
 @IN_MV_CUSMED    Char(01),
 @IN_MV_CUSFIL    Char(01),
 @IN_MV_CUSEMP    Char(01),
 @IN_MV_MOEDACM   Char(05),
 @OUT_RESULTADO   Char(01) OutPut
)
as
/* ---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus P12 </v>
    Programa    -  <s> Custo Unificado On-Line (mata300.prx) </s>
    Descricao   -  <d> Calcula o custo unificado on-line para um range de produtos </d>
    Assinatura  -  <a> 001 </a>
    Entrada     -  <ri> @IN_FILIALCOR  - Filial corrente
                        @IN_MV_PAR03   - Produto De
                        @IN_MV_PAR04   - Produto Ate
                        @IN_MV_CUSMED  - Utiliza Custo On-Line
                        @IN_MV_CUSFIL  - Utiliza Custo Unificado por Filial
                        @IN_MV_CUSEMP  - Utiliza Custo Unificado por Empresa
                        @IN_MV_MOEDACM - Moedas a serem processadas  </ri>

    Saida       -  <ro>  </ro>

    Responsavel :  <r> Marcos Vinicius Ferreira </r>
    Data        :  <dt> 22.06.2009 </dt>
--------------------------------------------------------------------------------------------------------------------- */
Declare @cFil_SB2        char('B2_FILIAL')
Declare @cProduto        char('B1_COD')
Declare @cAux            varchar(3)
Declare @nOUT_VLR1       float
Declare	@nOUT_VLR2       float
Declare	@nOUT_VLR3       float
Declare	@nOUT_VLR4       float
Declare	@nOUT_VLR5       float
Declare @iPos            integer

Begin
   select @OUT_RESULTADO = '0'
   select @cAux = 'SB2'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB2 OutPut

   /* ------------------------------------------------------------------------------------------------------------------
      Declara cursor para a Select de Produtos a Serem calculados 
   ------------------------------------------------------------------------------------------------------------------ */
   declare PROD_UNIFICADO insensitive cursor for
      select B1_COD 
        from SB1### (NoLock) 
       Where B1_COD between @IN_MV_PAR03 and @IN_MV_PAR04
         and B1_COD not LIKE 'MOD%' 
         and D_E_L_E_T_  = ' '
   for read only
   
   open PROD_UNIFICADO
   
   fetch PROD_UNIFICADO into @cProduto
   
   while (@@Fetch_Status = 0) begin

      /* ------------------------------------------------------------------------------------------------------------------
         Inicializa as variaveis com ZERO
      ------------------------------------------------------------------------------------------------------------------ */
      select @nOUT_VLR1 = 0
      select @nOUT_VLR2 = 0
      select @nOUT_VLR3 = 0
      select @nOUT_VLR4 = 0
      select @nOUT_VLR5 = 0

      /* ------------------------------------------------------------------------------------------------------------------
         Retorna o custo medio unificado do produto
      ------------------------------------------------------------------------------------------------------------------ */
      exec MAT051_## @IN_FILIALCOR, @cProduto, @IN_MV_CUSFIL, @IN_MV_MOEDACM, @nOUT_VLR1 OutPut, @nOUT_VLR2 OutPut, @nOUT_VLR3 OutPut, @nOUT_VLR4 OutPut, @nOUT_VLR5 OutPut

      if @IN_MV_CUSMED = '1' and @IN_MV_CUSFIL = '1' begin
         Update SB2### 
            set B2_VATU1  =  (B2_QATU * @nOUT_VLR1),
                B2_CM1    =  @nOUT_VLR1
          where B2_FILIAL = @cFil_SB2 
            and B2_COD    = @cProduto
            and D_E_L_E_T_ = ' '
         select @iPos = Charindex( '2', @IN_MV_MOEDACM )
         If @iPos > 0 begin    --Moeda 2
            Update SB2### 
               set B2_VATU2  =  (B2_QATU * @nOUT_VLR2),
                   B2_CM2    =  @nOUT_VLR2
             where B2_FILIAL = @cFil_SB2 
               and B2_COD    = @cProduto
               and D_E_L_E_T_ = ' '
         End
         select @iPos = Charindex( '3', @IN_MV_MOEDACM )
         If @iPos > 0 begin    --Moeda 3
            Update SB2### 
               set B2_VATU3  =  (B2_QATU * @nOUT_VLR3),
                   B2_CM3    =  @nOUT_VLR3
             where B2_FILIAL = @cFil_SB2 
               and B2_COD    = @cProduto
               and D_E_L_E_T_= ' '
         End
         select @iPos = Charindex( '4', @IN_MV_MOEDACM )
         If @iPos > 0 begin    --Moeda 4
            Update SB2### 
               set B2_VATU4  =  (B2_QATU * @nOUT_VLR4),
                   B2_CM4    =  @nOUT_VLR4
             where B2_FILIAL = @cFil_SB2 
               and B2_COD    = @cProduto
               and D_E_L_E_T_ = ' '
         End
         select @iPos = Charindex( '5', @IN_MV_MOEDACM )
         If @iPos > 0 begin    --Moeda 5
            Update SB2### 
               set B2_VATU5  =  (B2_QATU * @nOUT_VLR5),
                   B2_CM5    =  @nOUT_VLR5
             where B2_FILIAL = @cFil_SB2 
               and B2_COD    = @cProduto
               and D_E_L_E_T_ = ' '
         End
      End else begin
         If @IN_MV_CUSMED = '1' and @IN_MV_CUSEMP = '1' begin
            Update SB2### 
               set B2_VATU1  =  (B2_QATU * @nOUT_VLR1),
                   B2_CM1    =  @nOUT_VLR1
             where B2_COD    = @cProduto
               and D_E_L_E_T_ = ' '
            select @iPos = Charindex( '2', @IN_MV_MOEDACM )
            If @iPos > 0 begin    --Moeda 2
               Update SB2### 
                  set B2_VATU2  =  (B2_QATU * @nOUT_VLR2),
                      B2_CM2    =  @nOUT_VLR2
                where B2_COD    = @cProduto
                  and D_E_L_E_T_ = ' '
            End
            select @iPos = Charindex( '3', @IN_MV_MOEDACM )
            If @iPos > 0 begin    --Moeda 3
               Update SB2### 
                  set B2_VATU3  =  (B2_QATU * @nOUT_VLR3),
                      B2_CM3    =  @nOUT_VLR3
                where B2_COD    = @cProduto
                  and D_E_L_E_T_ = ' '
            End
            select @iPos = Charindex( '4', @IN_MV_MOEDACM )
            If @iPos > 0 begin    --Moeda 4
               Update SB2### 
                  set B2_VATU4  =  (B2_QATU * @nOUT_VLR4),
                      B2_CM4    =  @nOUT_VLR4
                where B2_COD    = @cProduto
                  and D_E_L_E_T_ = ' '
            End
            select @iPos = Charindex( '5', @IN_MV_MOEDACM )
            If @iPos > 0 begin    --Moeda 5
               Update SB2### 
                  set B2_VATU5  =  (B2_QATU * @nOUT_VLR5),
                      B2_CM5    =  @nOUT_VLR5
                where B2_COD    = @cProduto
                  and D_E_L_E_T_ = ' '
            End
         End
      End
      /* --------------------------------------------------------------------------------------------------------------
          Tratamento para o DB2 / MySQL
      -------------------------------------------------------------------------------------------------------------- */
      ##IF_001({|| AllTrim(Upper(TcGetDB())) == "DB2" .or. AllTrim(Upper(TcGetDB())) == "MYSQL" })
      SELECT @fim_CUR = 0
      ##ENDIF_001

      fetch PROD_UNIFICADO into @cProduto
   
   End

   close PROD_UNIFICADO
   deallocate PROD_UNIFICADO

   select @OUT_RESULTADO = '1'
End