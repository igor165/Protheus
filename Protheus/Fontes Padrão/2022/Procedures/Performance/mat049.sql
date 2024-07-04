Create procedure MAT049_##
( 
 @IN_CCOD         Char('B1_COD'),
 @IN_CLOCAL       Char('B1_LOCPAD'),
 @IN_DDATA        Char(08),
 @IN_FILIALCOR    Char('B1_FILIAL'),
 @OUT_QSALDOATU   Float OutPut,
 @OUT_CUSTOATU    Float OutPut,
 @OUT_CUSTOATU2   Float OutPut,
 @OUT_CUSTOATU3   Float OutPut,
 @OUT_CUSTOATU4   Float OutPut,
 @OUT_CUSTOATU5   Float OutPut,
 @OUT_QT2UM       Float OutPut
)

as
/* ---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus P12 </v>
    Programa    -  <s> CALCESTFF </s>
    Assinatura  -  <a> 001 </a>
    Descricao   -  <d> Retorna o Saldo Inicial por Produto / Local do arquivo SCC - Saldos Iniciais. (Custo Fifo) </d>
    Entrada     -  <ri>
                   @IN_CCOD         - Codigo do Produto
                   @IN_CLOCAL       - Local de Processamento (Almoxarifado)
                   @IN_DDATA        - Data para obter Saldo Inicial
                   @IN_FILIALCOR    - Filial Corrente
                   </ri>
    Saida       -  <ro>
                   @OUT_QSALDOATU   - Retorna o Saldo Atual do Produto
                   @OUT_CUSTOATU    - Retorno Custo 1
                   @OUT_CUSTOATU2   - Retorno Custo 2
                   @OUT_CUSTOATU3   - Retorno Custo 3
                   @OUT_CUSTOATU4   - Retorno Custo 4
                   @OUT_CUSTOATU5   - Retorno Custo 5
                   @OUT_QT2UM       - Retorno Quantidade na Segunda Unidade
                   </ro>

    Responsavel :  <r> Marcelo Pimentel </r>
    Data        :  <dt> 22.10.07 </dt>

    Estrutura de chamadas
    ========= == ========
    0.MAT048 - Retorna o Saldo do Produto/Local do arquivo SCC - Saldos Iniciais (Custo Fifo)
--------------------------------------------------------------------------------------------------------------------- */
Declare @cFil_SCC       VarChar( 'D8_FILIAL' )
Declare @cFil_SD8       VarChar( 'D8_FILIAL' )
Declare @cDtVai         Varchar(08)
Declare @cDtAux         VarChar(08)
Declare @cAux           Varchar(03)
Declare @cD8_PRODUTO    VarChar( 'D8_PRODUTO' )
Declare @cD8_LOCAL      VarChar( 'D8_LOCAL' )
Declare @cD8_SEQ        VarChar( 'D8_SEQ' )
Declare @cD8_TM         VarChar( 'D8_TM' )

Declare @nCC_QFIM       decimal( 'D8_QUANT' )
Declare @nCC_VFIMFF1    decimal( 'D8_CUSTO1' )
Declare @nCC_VFIMFF2    decimal( 'D8_CUSTO2' )
Declare @nCC_VFIMFF3    decimal( 'D8_CUSTO3' )
Declare @nCC_VFIMFF4    decimal( 'D8_CUSTO4' )
Declare @nCC_VFIMFF5    decimal( 'D8_CUSTO1' )
Declare @nCC_QFIM2UM    decimal( 'D8_QT2UM' )

Declare @nTCC_QFIM      decimal( 'D8_QUANT' )
Declare @nTCC_VFIMFF1   decimal( 'D8_CUSTO1' )
Declare @nTCC_VFIMFF2   decimal( 'D8_CUSTO2' )
Declare @nTCC_VFIMFF3   decimal( 'D8_CUSTO3' )
Declare @nTCC_VFIMFF4   decimal( 'D8_CUSTO4' )
Declare @nTCC_VFIMFF5   decimal( 'D8_CUSTO1' )
Declare @nTCC_QFIM2UM   decimal( 'D8_QT2UM' )

Declare @nD8_QUANT      decimal( 'D8_QUANT' )
Declare @nD8_CUSTO1     decimal( 'D8_CUSTO1' )
Declare @nD8_CUSTO2     decimal( 'D8_CUSTO2' )
Declare @nD8_CUSTO3     decimal( 'D8_CUSTO3' )
Declare @nD8_CUSTO4     decimal( 'D8_CUSTO4' )
Declare @nD8_CUSTO5     decimal( 'D8_CUSTO5' )
Declare @nD8_QT2UM      decimal( 'D8_QT2UM' )

Declare @nTQTDE      decimal( 'D8_QUANT' )
Declare @nTCUSTO1    decimal( 'D8_CUSTO1' )
Declare @nTCUSTO2    decimal( 'D8_CUSTO2' )
Declare @nTCUSTO3    decimal( 'D8_CUSTO3' )
Declare @nTCUSTO4    decimal( 'D8_CUSTO4' )
Declare @nTCUSTO5    decimal( 'D8_CUSTO5' )
Declare @nTQT2UM     decimal( 'D8_QT2UM' )

begin
  select @cDtVai       = '19800101'
  Select @cDtAux       = '19800101'
  select @nCC_QFIM     = 0
  select @nCC_VFIMFF1  = 0
  select @nCC_VFIMFF2  = 0
  select @nCC_VFIMFF3  = 0
  select @nCC_VFIMFF4  = 0
  select @nCC_VFIMFF5  = 0
  select @nCC_QFIM2UM  = 0

  select @nTCC_QFIM    = 0
  select @nTCC_VFIMFF1 = 0
  select @nTCC_VFIMFF2 = 0
  select @nTCC_VFIMFF3 = 0
  select @nTCC_VFIMFF4 = 0
  select @nTCC_VFIMFF5 = 0
  select @nTCC_QFIM2UM = 0

  select @nD8_QUANT    = 0
  select @nD8_CUSTO1   = 0
  select @nD8_CUSTO2   = 0
  select @nD8_CUSTO3   = 0
  select @nD8_CUSTO4   = 0
  select @nD8_CUSTO5   = 0
  select @nD8_QT2UM    = 0

  select @nTQTDE       = 0
  select @nTCUSTO1     = 0
  select @nTCUSTO2     = 0
  select @nTCUSTO3     = 0
  select @nTCUSTO4     = 0
  select @nTCUSTO5     = 0
  select @nTQT2UM      = 0
  
  ##FIELDP01( 'SCC.CC_SEQ' )
  select @cAux = 'SCC'
  EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SCC OutPut
  select @cAux = 'SD8'
  EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SD8 OutPut

  /* ------------------------------------------------------------------------------
    Recupera Data para compor o Saldo Atualiza Valores Iniciais 
  ------------------------------------------------------------------------------ */
  -- Declaracao do cursor CUR_SCC
  declare CUR_SCC INSENSITIVE  cursor for 

  /* ----------------------------------------------------------------------------------
     Tratamento para o OpenEdge:
	 O 'SELECT' abaixo pode obter vários registros, porém todos na mesma CC_DATA, 
	 já que está sendo usada a cláusula " max ( substring ( CC_DATA , 1 , 8 )) " como
	 restrição do WHERE principal. Neste caso a procedure MSDATEADD pode ser executada 
	 somente uma vez ao final do laço feito no cursor aberto por este 'SELECT'.
     --------------------------------------------------------------------------------- */
  ##IF_001({|| AllTrim(Upper(TcGetDB())) <> "OPENEDGE" })

  select CC_QFIM, CC_VFIMFF1, CC_VFIMFF2,  CC_VFIMFF3, CC_VFIMFF4, 
         CC_VFIMFF5, CC_QFIM2UM , CONVERT( Char( 08 ) ,DATEADD ( DAY , 1 , CC_DATA ),112 )
  
  ##ELSE_001
  
  select CC_QFIM, CC_VFIMFF1, CC_VFIMFF2,  CC_VFIMFF3, CC_VFIMFF4, 
         CC_VFIMFF5, CC_QFIM2UM , CC_DATA
  
  ##ENDIF_001

    from SCC### 
   where CC_FILIAL  = @cFil_SCC  
     and CC_PRODUTO = @IN_CCOD  
     and CC_LOCAL   = @IN_CLOCAL  
     and CC_DATA    = ( select max ( substring ( CC_DATA , 1 , 8 ))
                          from SCC### 
                         where CC_FILIAL  = @cFil_SCC  
                           and CC_PRODUTO = @IN_CCOD  
                           and CC_LOCAL   = @IN_CLOCAL  
                           and D_E_L_E_T_ = ' ' ) 
     and D_E_L_E_T_  = ' ' 
  for read only 

  open CUR_SCC
  fetch CUR_SCC into @nCC_QFIM, @nCC_VFIMFF1, @nCC_VFIMFF2, @nCC_VFIMFF3, @nCC_VFIMFF4, @nCC_VFIMFF5, @nCC_QFIM2UM, @cDtVai

  while (@@fetch_status  = 0) begin

    if @nCC_QFIM    is null select @nCC_QFIM    = 0
    if @nCC_VFIMFF1 is null select @nCC_VFIMFF1 = 0
    if @nCC_VFIMFF2 is null select @nCC_VFIMFF2 = 0
    if @nCC_VFIMFF3 is null select @nCC_VFIMFF3 = 0
    if @nCC_VFIMFF4 is null select @nCC_VFIMFF4 = 0
    if @nCC_VFIMFF5 is null select @nCC_VFIMFF5 = 0
    if @nCC_QFIM2UM is null select @nCC_QFIM2UM = 0

    select @nTCC_QFIM    = @nTCC_QFIM    + @nCC_QFIM
    select @nTCC_VFIMFF1 = @nTCC_VFIMFF1 + @nCC_VFIMFF1
    select @nTCC_VFIMFF2 = @nTCC_VFIMFF2 + @nCC_VFIMFF2
    select @nTCC_VFIMFF3 = @nTCC_VFIMFF3 + @nCC_VFIMFF3
    select @nTCC_VFIMFF4 = @nTCC_VFIMFF4 + @nCC_VFIMFF4
    select @nTCC_VFIMFF5 = @nTCC_VFIMFF5 + @nCC_VFIMFF5     
    select @nTCC_QFIM2UM = @nTCC_QFIM2UM + @nCC_QFIM2UM
    /* --------------------------------------------------------------------------------------------------------------
       Tratamento para o DB2 / MySQL
    -------------------------------------------------------------------------------------------------------------- */
    ##IF_002({|| AllTrim(Upper(TcGetDB())) == "DB2" .Or. AllTrim(Upper(TcGetDB())) == "MYSQL" })
    SELECT @fim_CUR = 0
    ##ENDIF_002
    fetch CUR_SCC into @nCC_QFIM, @nCC_VFIMFF1, @nCC_VFIMFF2, @nCC_VFIMFF3, @nCC_VFIMFF4, @nCC_VFIMFF5, @nCC_QFIM2UM, @cDtVai
  end
  close CUR_SCC
  deallocate CUR_SCC

  /* ----------------------------------------------------------------------------------
     Tratamento para o OpenEdge
     --------------------------------------------------------------------------------- */
  ##IF_003({|| AllTrim(Upper(TcGetDB())) == "OPENEDGE" })
  
	Select @cDtAux = @cDtVai
  
    EXEC MSDATEADD 'DAY', 1, @cDtAux, @cDtVai OutPut
  
  ##ENDIF_003
  
  if @nTCC_QFIM    is null select @nTCC_QFIM    = 0
  if @nTCC_VFIMFF1 is null select @nTCC_VFIMFF1 = 0
  if @nTCC_VFIMFF2 is null select @nTCC_VFIMFF2 = 0
  if @nTCC_VFIMFF3 is null select @nTCC_VFIMFF3 = 0
  if @nTCC_VFIMFF4 is null select @nTCC_VFIMFF4 = 0
  if @nTCC_VFIMFF5 is null select @nTCC_VFIMFF5 = 0
  if @nTCC_QFIM2UM is null select @nTCC_QFIM2UM = 0
  if @cDtVai       is null select @cDtVai = '19800101'
  if @cDtVai       = ' '   select @cDtVai = '19800101'

  /* ------------------------------------------------------------------------------
    Obtem o saldo Movimento p/ lote custo fifo (SD8) 
  ------------------------------------------------------------------------------ */
  declare CUR_SD8 INSENSITIVE cursor for
    select D8_PRODUTO,D8_LOCAL,D8_SEQ,D8_TM,D8_QUANT,D8_QT2UM,D8_CUSTO1,D8_CUSTO2,D8_CUSTO3,D8_CUSTO4,D8_CUSTO5
      from SD8### SD8 (nolock)
     where D8_FILIAL      = @cFil_SD8
       and SD8.D8_PRODUTO = @IN_CCOD
       and SD8.D8_LOCAL   = @IN_CLOCAL
       and D8_TIPONF     <> 'E'
       and D8_DATA       >= @cDtVai
       and D8_DATA       <  @IN_DDATA
       and D_E_L_E_T_    = ' '
     for read only               
     open CUR_SD8
     fetch CUR_SD8 into @cD8_PRODUTO,@cD8_LOCAL,@cD8_SEQ,@cD8_TM,@nD8_QUANT,@nD8_QT2UM,@nD8_CUSTO1,@nD8_CUSTO2,@nD8_CUSTO3,@nD8_CUSTO4,@nD8_CUSTO5
      
      while (@@fetch_status = 0) begin

         If @nD8_QUANT   is null select @nD8_QUANT   = 0
         If @nD8_CUSTO1  is null select @nD8_CUSTO1  = 0
         If @nD8_CUSTO2  is null select @nD8_CUSTO2  = 0
         If @nD8_CUSTO3  is null select @nD8_CUSTO3  = 0
         If @nD8_CUSTO4  is null select @nD8_CUSTO4  = 0
         If @nD8_CUSTO5  is null select @nD8_CUSTO5  = 0
         If @nD8_QT2UM   is null select @nD8_QT2UM   = 0
         If @cD8_TM      is null select @cD8_TM      = ''

         If @cD8_TM > '500' begin
             select @nTQTDE    = @nTQTDE   - @nD8_QUANT
             select @nTCUSTO1  = @nTCUSTO1 - @nD8_CUSTO1
             select @nTCUSTO2  = @nTCUSTO2 - @nD8_CUSTO2
             select @nTCUSTO3  = @nTCUSTO3 - @nD8_CUSTO3
             select @nTCUSTO4  = @nTCUSTO4 - @nD8_CUSTO4
             select @nTCUSTO5  = @nTCUSTO5 - @nD8_CUSTO5
             select @nTQT2UM   = @nTQT2UM  - @nD8_QT2UM
         end else begin
             select @nTQTDE    = @nTQTDE   + @nD8_QUANT
             select @nTCUSTO1  = @nTCUSTO1 + @nD8_CUSTO1
             select @nTCUSTO2  = @nTCUSTO2 + @nD8_CUSTO2
             select @nTCUSTO3  = @nTCUSTO3 + @nD8_CUSTO3
             select @nTCUSTO4  = @nTCUSTO4 + @nD8_CUSTO4
             select @nTCUSTO5  = @nTCUSTO5 + @nD8_CUSTO5
             select @nTQT2UM   = @nTQT2UM  + @nD8_QT2UM
         end 
        /* --------------------------------------------------------------------------------------------------------------
           Tratamento para o DB2 / MySQL
        -------------------------------------------------------------------------------------------------------------- */
        ##IF_004({|| AllTrim(Upper(TcGetDB())) == "DB2" .Or. AllTrim(Upper(TcGetDB())) == "MYSQL" })
        SELECT @fim_CUR = 0
        ##ENDIF_004
        fetch CUR_SD8 into @cD8_PRODUTO,@cD8_LOCAL,@cD8_SEQ,@cD8_TM,@nD8_QUANT,@nD8_QT2UM,@nD8_CUSTO1,@nD8_CUSTO2,@nD8_CUSTO3,@nD8_CUSTO4,@nD8_CUSTO5
	  end
    close CUR_SD8
    deallocate CUR_SD8

  if @nTQTDE    is null select @nTQTDE    = 0
  if @nTCUSTO1  is null select @nTCUSTO1  = 0
  if @nTCUSTO2  is null select @nTCUSTO2  = 0
  if @nTCUSTO3  is null select @nTCUSTO3  = 0
  if @nTCUSTO4  is null select @nTCUSTO4  = 0
  if @nTCUSTO5  is null select @nTCUSTO5  = 0
  if @nTQT2UM   is null select @nTQT2UM   = 0

  ##ENDFIELDP01

  select @OUT_QSALDOATU = (@nTCC_QFIM      + @nTQTDE)
  select @OUT_CUSTOATU  = (@nTCC_VFIMFF1   + @nTCUSTO1)
  select @OUT_CUSTOATU2 = (@nTCC_VFIMFF2   + @nTCUSTO2)
  select @OUT_CUSTOATU3 = (@nTCC_VFIMFF3   + @nTCUSTO3)
  select @OUT_CUSTOATU4 = (@nTCC_VFIMFF4   + @nTCUSTO4)
  select @OUT_CUSTOATU5 = (@nTCC_VFIMFF5   + @nTCUSTO5)
  select @OUT_QT2UM     = (@nTCC_QFIM2UM   + @nTQT2UM)

end
