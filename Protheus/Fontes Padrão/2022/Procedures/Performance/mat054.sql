Create procedure MAT054_##
(
   @IN_FILIALCOR    char('B1_FILIAL'),
   @IN_CFILAUX      char('B1_FILIAL'),
   @IN_DINICIO      char(08),
   @IN_MV_MOEDACM   char(05),
   @IN_MV_PAR1      char(08),
   @IN_MV_CUSFIFO   char(01),
   @OUT_RESULTADO   char(01) Output
)
as
/* ---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus P12 </v>
    Programa    -  <s> A330INICIA (MATA330) </s>
    Assinatura  -  <a> 007 </a>
    Descricao   -  <d> Pega valores do inicio do periodo para serem reprocessados - Custo FIFO/LIFO </d>
    Entrada     -  <ri>
                   @IN_FILIALCOR    - Filial Corrente
                   @IN_CFILAUX      - Filial Auxiliar
                   @IN_DINICIO      - Data de inicio do Processo - MV_UMES
                   @IN_MV_MOEDACM   - Configuracao das moedas utilizadas - MV_MOEDACM
                   @IN_MV_PAR1      - Data final de processamento
                   @IN_MV_CUSFIFO   - Verifica se utiliza custo FIFO - MV_CUSFIFO
                  </ri>

    Saida          <ro> @OUT_RESULT      - Status da execucao do processo </ro>

    Responsavel :  <r> Marcos Vinicius Ferreira </r>
    Data        :  <dt> 11/09/2008 </dt>

    Estrutura de chamadas
    ========= == ========

      0.MAT054 - Pega valores do inicio do periodo para serem reprocessados - Custo FIFO/LIFO

--------------------------------------------------------------------------------------------------------------------- */
declare @cFil_SBD      char('BD_FILIAL')
declare @cFil_SD8      char('D8_FILIAL')
declare @cFil_SCC      char('D8_FILIAL')
declare @cCC_DATA      char('D8_DATA')
declare @cCC_PRODUTO   char('D8_PRODUTO')
declare @cCC_LOCAL     char('D8_LOCAL')
declare @cCC_DTORIG    char('D8_DATA')
declare @cCC_SEQ       char('D8_SEQ')
declare @cBD_PRODUTO   char('BD_PRODUTO')
declare @cBD_LOCAL     char('BD_LOCAL')
declare @cBD_SEQ       char('BD_SEQ')
declare @cFILAUX       char('B1_FILIAL')
declare @cFiltra       char(01)
declare @cAux          Varchar(03)
declare @iPos          integer
declare @iRecno        integer
Declare @iMaxRecno     integer
Declare @iRec          integer
Declare @iRecAnt       integer
declare @vBD_CUSINI2   decimal( 'BD_CUSINI2' )
declare @vBD_CUSINI3   decimal( 'BD_CUSINI3' )
declare @vBD_CUSINI4   decimal( 'BD_CUSINI4' )
declare @vBD_CUSINI5   decimal( 'BD_CUSINI5' )
declare @vBD_CUSFIM2   decimal( 'BD_CUSFIM2' )
declare @vBD_CUSFIM3   decimal( 'BD_CUSFIM3' )
declare @vBD_CUSFIM4   decimal( 'BD_CUSFIM4' )
declare @vBD_CUSFIM5   decimal( 'BD_CUSFIM5' )
declare @vD8_CUSTO2    decimal( 'D8_CUSTO2' )
declare @vD8_CUSTO3    decimal( 'D8_CUSTO3' )
declare @vD8_CUSTO4    decimal( 'D8_CUSTO4' )
declare @vD8_CUSTO5    decimal( 'D8_CUSTO5' )
declare @vCC_QINI      decimal( 'D8_QUANT' )
declare @vCC_QINI2UM   decimal( 'D8_QT2UM' )
declare @vCC_VINIFF1   decimal( 'D8_CUSTO1' )
declare @vCC_VINIFF2   decimal( 'D8_CUSTO2' )
declare @vCC_VINIFF3   decimal( 'D8_CUSTO3' )
declare @vCC_VINIFF4   decimal( 'D8_CUSTO4' )
declare @vCC_VINIFF5   decimal( 'D8_CUSTO5' )
declare @vCC_QFIM      decimal( 'D8_QUANT' )
declare @vCC_VFIMFF1   decimal( 'D8_CUSTO1' )
declare @vCC_VFIMFF2   decimal( 'D8_CUSTO2' )
declare @vCC_VFIMFF3   decimal( 'D8_CUSTO3' )
declare @vCC_VFIMFF4   decimal( 'D8_CUSTO4' )
declare @vCC_VFIMFF5   decimal( 'D8_CUSTO5' )
declare @vCC_QFIM2UM   decimal( 'D8_QT2UM' )

begin
  /* --------------------------------------------------------------------------------------------
   Define inicio do processo
  -------------------------------------------------------------------------------------------- */
   select @OUT_RESULTADO = '0'
   select @cFiltra       = '0'
   select @cFILAUX       = @IN_CFILAUX
   if @cFILAUX is Null select @cFILAUX = '  '
   select @cAux = 'SBD'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SBD OutPut
   ##FIELDP01( 'SCC.CC_SEQ' )
   select @cAux = 'SD8'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SD8 OutPut
   select @cAux = 'SCC'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SCC OutPut
   ##ENDFIELDP01

   /* ---------------------------------------------------------------------------------------------------------------
      Custo Fifo / Lifo
   --------------------------------------------------------------------------------------------------------------- */
   ##FIELDP02( 'SCC.CC_SEQ' )
   If @IN_MV_CUSFIFO = '1' begin
      /* ---------------------------------------------------------------------------------------------------------------
         Apaga os lotes do ultimo calculo
      --------------------------------------------------------------------------------------------------------------- */
      delete
        from SBD###
       where BD_FILIAL   =  @cFil_SBD
         and BD_DTPROC   >= @IN_DINICIO
         and D_E_L_E_T_  = ' '
      /* ---------------------------------------------------------------------------------------------------------------
         Estorna quantidades lancadas no ultimo recalculo e acerta os campos D8_SD1DEV e D8_QFIMDEV
      --------------------------------------------------------------------------------------------------------------- */
      select @iMaxRecno = isnull( max( R_E_C_N_O_ ), 0 )
        from SD8### (nolock)
       where D8_FILIAL  = @cFil_SD8
         and D_E_L_E_T_ = ' '
      select @iRec = 0
      while ( @iRec <= @iMaxRecno ) begin
          select @iRecAnt = @iRec
          select @iRec = @iRec + 1024

          update SD8###
             set D8_SD1DEV  = D8_SD1DEV - D8_QFIMDEV, D8_QFIMDEV = 0
           where R_E_C_N_O_ between @iRecAnt and @iRec
             and D8_FILIAL  = @cFil_SD8
             and D8_QFIMDEV > 0
             and D8_TM      > '500'
             and D8_ITEM    <> ' '
             and D_E_L_E_T_ =  ' '
      end

      /* ---------------------------------------------------------------------------------------------------------------
         Apaga os movimento de lotes SD8 referentes ao ultimo calculo
      --------------------------------------------------------------------------------------------------------------- */
      delete
        from SD8###
       where D8_FILIAL   =  @cFil_SD8
         and D8_DTPROC   >= @IN_DINICIO
         and D_E_L_E_T_  = ' '
      /* ---------------------------------------------------------------------------------------------------------------
         Inicializa os Saldos Iniciais Fifo baseado na tabela SCC
      --------------------------------------------------------------------------------------------------------------- */
      declare CUR_SCC insensitive cursor for
       select CC_PRODUTO,CC_LOCAL  ,CC_DTORIG ,CC_SEQ    ,CC_QFIM   ,CC_VFIMFF1,CC_VFIMFF2,CC_VFIMFF3,CC_VFIMFF4,CC_VFIMFF5,
              CC_QFIM2UM,CC_QINI   ,CC_QINI2UM,CC_VINIFF1,CC_VINIFF2,CC_VINIFF3,CC_VINIFF4,CC_VINIFF5, CC_DATA
         from SCC### SCC (nolock)
        where CC_FILIAL   = @cFil_SCC
          and CC_STATUS   = 'A'
          and D_E_L_E_T_  = ' '
      open CUR_SCC
      fetch CUR_SCC into @cCC_PRODUTO,@cCC_LOCAL  ,@cCC_DTORIG ,@cCC_SEQ    ,@vCC_QFIM   ,@vCC_VFIMFF1,@vCC_VFIMFF2,@vCC_VFIMFF3,@vCC_VFIMFF4,
                         @vCC_VFIMFF5,@vCC_QFIM2UM,@vCC_QINI   ,@vCC_QINI2UM,@vCC_VINIFF1,@vCC_VINIFF2,@vCC_VINIFF3,@vCC_VINIFF4,@vCC_VINIFF5, @cCC_DATA
      while @@fetch_status = 0 begin
        select @iRecno     = null
        select @iRecno     = R_E_C_N_O_
          from SBD### (nolock)
         where BD_FILIAL   = @cFil_SBD
           and BD_SEQ      = @cCC_SEQ
           and D_E_L_E_T_  = ' '
        if @iRecno is null begin
           select @iRecno = IsNull( max(R_E_C_N_O_), 0 ) from SBD###
           select @iRecno = @iRecno + 1
           insert into SBD### ( BD_FILIAL , BD_PRODUTO   , BD_LOCAL   , BD_DATA    , BD_SEQ   , BD_DTCALC   , R_E_C_N_O_, BD_STATUS, BD_QINI   , BD_QINI2UM   , BD_CUSINI1   , BD_QFIM   , BD_QFIM2UM   , BD_CUSFIM1   , BD_DTPROC   , BD_CUSINI2   , BD_CUSFIM2   , BD_CUSINI3   , BD_CUSFIM3   , BD_CUSINI4   , BD_CUSFIM4   , BD_CUSINI5   , BD_CUSFIM5   )
                       values ( @cFil_SBD , @cCC_PRODUTO , @cCC_LOCAL , @cCC_DTORIG, @cCC_SEQ , @IN_MV_PAR1 , @iRecno   , ' '      , @vCC_QINI , @vCC_QINI2UM , @vCC_VINIFF1 , @vCC_QFIM , @vCC_QFIM2UM , @vCC_VFIMFF1 , @IN_MV_PAR1 , @vCC_VINIFF2 , @vCC_VFIMFF2 , @vCC_VINIFF3 , @vCC_VFIMFF3 , @vCC_VINIFF4 , @vCC_VFIMFF4 , @vCC_VINIFF5 , @vCC_VFIMFF5 )
        end else begin
           select @vBD_CUSINI2 = 0
           select @vBD_CUSINI3 = 0
           select @vBD_CUSINI4 = 0
           select @vBD_CUSINI5 = 0
           select @vBD_CUSFIM2 = 0
           select @vBD_CUSFIM3 = 0
           select @vBD_CUSFIM4 = 0
           select @vBD_CUSFIM5 = 0
           select @iPos = Charindex( '2', @IN_MV_MOEDACM )
           If @iPos > 0 begin
              select @vBD_CUSINI2 = @vCC_VINIFF2
              select @vBD_CUSFIM2 = @vCC_VFIMFF2
           End
           select @iPos = Charindex( '3', @IN_MV_MOEDACM )
           If @iPos > 0 begin
              select @vBD_CUSINI3 = @vCC_VINIFF3
              select @vBD_CUSFIM3 = @vCC_VFIMFF3
           End
           select @iPos = Charindex( '4', @IN_MV_MOEDACM )
           If @iPos > 0 begin
              select @vBD_CUSINI4 = @vCC_VINIFF4
              select @vBD_CUSFIM4 = @vCC_VFIMFF4
           End
           select @iPos = Charindex( '5', @IN_MV_MOEDACM )
           If @iPos > 0 begin
              select @vBD_CUSINI5 = @vCC_VINIFF5
              select @vBD_CUSFIM5 = @vCC_VFIMFF5
           End
           update SBD###
              set BD_STATUS  = ' '         , BD_QINI     = @vCC_QINI    , BD_QINI2UM = @vCC_QINI2UM , BD_CUSINI1 = @vCC_VINIFF1,
                  BD_QFIM    = @vCC_QFIM   , BD_QFIM2UM  = @vCC_QFIM2UM , BD_CUSFIM1 = @vCC_VFIMFF1 , BD_DTPROC  = @IN_MV_PAR1,
                  BD_CUSINI2 = @vBD_CUSINI2, BD_CUSFIM2  = @vCC_VFIMFF2 , BD_CUSINI3 = @vBD_CUSINI3, BD_CUSFIM3  = @vCC_VFIMFF3,
                  BD_CUSINI4 = @vBD_CUSINI4, BD_CUSFIM4  = @vCC_VFIMFF4 , BD_CUSINI5 = @vBD_CUSINI5, BD_CUSFIM5  = @vCC_VFIMFF5
            where R_E_C_N_O_ = @iRecno
        end
        /* --------------------------------------------------------------------------------------------------------------
           Verifica se saldo inicial foi gerado manualmente, caso seja serah gerado o registro de movimento inicial
        -------------------------------------------------------------------------------------------------------------- */
        if @cCC_DATA = ' ' begin
           select @vD8_CUSTO2 = 0
           select @vD8_CUSTO3 = 0
           select @vD8_CUSTO4 = 0
           select @vD8_CUSTO5 = 0
           select @iPos = Charindex( '2', @IN_MV_MOEDACM )
           If @iPos > 0 begin
              select @vD8_CUSTO2 = @vCC_VINIFF2
           End
           select @iPos = Charindex( '3', @IN_MV_MOEDACM )
           If @iPos > 0 begin
              select @vD8_CUSTO3 = @vCC_VINIFF3
           End
           select @iPos = Charindex( '4', @IN_MV_MOEDACM )
           If @iPos > 0 begin
              select @vD8_CUSTO4 = @vCC_VINIFF4
           End
           select @iPos = Charindex( '5', @IN_MV_MOEDACM )
           If @iPos > 0 begin
              select @vD8_CUSTO5 = @vCC_VINIFF5
           End
           select @iRecno = IsNull( max(R_E_C_N_O_), 0 ) from SD8###
           select @iRecno = @iRecno + 1
           insert into SD8### ( D8_FILIAL   , D8_PRODUTO  , D8_LOCAL    , D8_DATA   , D8_QUANT  , D8_QT2UM , D8_CUSTO1 , D8_CUSTO2,D8_CUSTO3 , D8_CUSTO4, D8_CUSTO5 , D8_TIPONF , D8_SEQ, D8_DTCALC, D8_DTPROC, R_E_C_N_O_ )
                       values ( @cFil_SD8   , @cCC_PRODUTO, @cCC_LOCAL  , @cCC_DATA , @vCC_QINI , @vCC_QFIM2UM , @vCC_VINIFF1, @vCC_VINIFF2,@vCC_VINIFF3, @vCC_VINIFF4, @vCC_VINIFF5, 'E', @cCC_SEQ, @IN_MV_PAR1  , @IN_MV_PAR1 , @iRecno )
        end
        /* --------------------------------------------------------------------------------------------------------------
           Tratamento para o DB2 / MySQL
        -------------------------------------------------------------------------------------------------------------- */
        ##IF_001({|| AllTrim(Upper(TcGetDB())) == "DB2" .Or. AllTrim(Upper(TcGetDB())) == "MYSQL" })
        SELECT @fim_CUR = 0
        ##ENDIF_001
        fetch CUR_SCC into @cCC_PRODUTO,@cCC_LOCAL  ,@cCC_DTORIG ,@cCC_SEQ    ,@vCC_QFIM   ,@vCC_VFIMFF1,@vCC_VFIMFF2,@vCC_VFIMFF3,@vCC_VFIMFF4,
                           @vCC_VFIMFF5,@vCC_QFIM2UM,@vCC_QINI   ,@vCC_QINI2UM,@vCC_VINIFF1,@vCC_VINIFF2,@vCC_VINIFF3,@vCC_VINIFF4,@vCC_VINIFF5, @cCC_DATA
      end
      close CUR_SCC
      deallocate CUR_SCC
   end
   ##ENDFIELDP02

   /* -------------------------------------------------------------------------
      Final do processo retornando '1' como processo  encerrado por completo
      ------------------------------------------------------------------------- */
   select @OUT_RESULTADO = '1'

end
