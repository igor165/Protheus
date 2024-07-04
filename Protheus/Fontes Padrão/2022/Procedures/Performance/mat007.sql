Create procedure MAT007_##
(
   @IN_FILIALCOR    char('B1_FILIAL'),
   @IN_CFILAUX      char('B1_FILIAL'),
   @IN_DINICIO      char(08),
   @IN_MV_LOCPROC   Char('B1_LOCPAD'),
   @IN_COPCOES      char(04),
   @IN_CUSUNIF      char(01),
   @IN_DDATABASE    char(08),
   @IN_MV_NEGESTR   char(01),
   @IN_MV_MOEDACM   char(05),
   @IN_MV_PAR1      char(08),
   @IN_MV_CUSFIFO   char(01),
   @IN_MV_PRODMNT   char('B1_COD'),
   @IN_MV_D3SERVI   char(01),
   @IN_INTDL        char(01),
   @IN_MV_CQ        char('B2_LOCAL'),
   @IN_MVULMES      char(08),
   @IN_MV_WMSNEW    Char('B1_LOCPAD'),
   @IN_MV_PRODMOD   char(01),
   @OUT_RESULTADO   char(01) Output
)
as
/* ATENÇÂO !!!!!! esta procedure esta no limite de tamanho, e a cada inclusão de novos trechos pode estourar
o limite de 32kb onde é validado no aplicador causando o erro Token GO. Existe a possibilidade de ajustar o aplicador, porem neste
momento ate que se ajuste, toda inserção de linhas deverá ser tratada em procedures a parte com chamadas nesta.

 ---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus P11 </v>
    Programa    -  <s> A330INICIA (MATA330) </s>
    Assinatura  -  <a> 007 </a>
    Descricao   -  <d> Pega valores do inicio do periodo para serem reprocessados </d>
    Entrada     -  <ri>
                   @IN_FILIALCOR    - Filial Corrente
                   @IN_CFILAUX      - Filial Auxiliar
                   @IN_DINICIO      - Data de inicio do Processo - MV_UMES
                   @IN_MV_LOCPROC   - Local padrao a ser enviado os materiais  indiretos em processo.
                   @IN_COPCOES      - 1a posicao - 1 Deve calcular o custo da MOD
                                      2a posicao - 1 Calcula o custo com apropriacao sequencial
                                      3a posicao - 1 Calcula o custo com apropriacao mensal
                                      4a posicao - 1 Calcula o custo com apropriacao diaria
                   @IN_CUSUNIF      - Indica se o custo é unificado
                   @IN_DDATABASE    - Data base do sistema
                   @IN_MV_NEGESTR   - Permiti Incluir Itens negativos na estrutura
                   @IN_FILSEQ       - Numero sequencial da Filial selecionada
                   @IN_MV_MOEDACM   - Conteudo do parametro MV_MOEDACM
                   @IN_MV_PAR1      - Data final de processamento
                   @IN_MV_CUSFIFO   - Parametro que indica se o processamento do custo FIFO esta ativado
                   @IN_MV_PRODMNT   - Codigo do produto Manutencao
                   @IN_MV_D3SERVI   - Conteudo do parametro MV_D3SERVI
                   @IN_INTDL        - Indica se utiliza a integracao com o DL/WMS
                   @IN_MV_CQ        - Armazem de controle de qualidade
                   @IN_MVULMES      - Conteudo do parametro MV_ULMES
                  </ri>

    Saida          <ro> @OUT_RESULT      - Status da execucao do processo </ro>

    Responsavel :  <r> Ricardo Gonçalves </r>
    Data        :  <dt> 16/07/2002 </dt>

    Estrutura de chamadas
    ========= == ========

    0.MAT007 - Pega valores do inicio do periodo para serem reprocessados
        1.MAT006 - Retorna o Saldo do Produto/Local do arquivo SB9 - Saldos Iniciais
        1.MAT043 - Verifica se pode alterar o custo medio do produto
        1.M330CMU - Pega valores de custo do produto quando o mesmo é sucata ( resíduo )
          2.MAT020  -  Recupera taxa para moeda na data em questao
        1.M330INB2CP - Gravar os Valores finais no SB2 com o CUSTO EM PARTES.
        1.M330INC2CP - Atualiza partes do custo em partes no SC2
        1.MAT054 - Atualiza o Saldo Inicial FIFO/LIFO

--------------------------------------------------------------------------------------------------------------------- */
declare @cCod          char('B1_COD')
declare @cLocal        char('B1_LOCPAD')
declare @cLocalOri     char('B1_LOCPAD')
declare @cFil_SB2      char('B2_FILIAL')
declare @cFil_SB1      char('B1_FILIAL')
declare @cFil_SC2      char('C2_FILIAL')
declare @cFil_SB9      char('B9_FILIAL')
declare @cFil_SD1      char('D1_FILIAL')
declare @cFil_SD2      char('D2_FILIAL')
declare @cFil_SD3      char('D3_FILIAL')
declare @cFil_SF4      char('F4_FILIAL')
declare @cCodOriMod    char('B1_COD')
declare @cB1_CC        char(01)
declare @cFILAUX       char('B1_FILIAL')
declare @cCusFilAux    char('B1_FILIAL')
declare @cFiltra       char(01)
declare @cExecutou     char(01)
declare @cAux          Varchar(03)
declare @OutResult     varchar(01)
declare @nSaldo01      decimal( 'B2_QFIM' )
declare @nSaldo02      decimal( 'B2_VFIM1' )
declare @nSaldo03      decimal( 'B2_VFIM2' )
declare @nSaldo04      decimal( 'B2_VFIM3' )
declare @nSaldo05      decimal( 'B2_VFIM4' )
declare @nSaldo06      decimal( 'B2_VFIM5' )
declare @nSaldo07      decimal( 'B2_QFIM2' )
declare @nVFim01       float
declare @nVFim02       float
declare @nVFim03       float
declare @nVFim04       float
declare @nVFim05       float
declare @nQFim01       float
declare @nQFim02       float
declare @nQFim03       float
declare @nQFim04       float
declare @nQFim05       float
declare @nTRB_QFIM     float
declare @nQtd          float
declare @nQSaldoAtuFF  float
declare @nCustoAtuFF01 float
declare @nCustoAtuFF02 float
declare @nCustoAtuFF03 float
declare @nCustoAtuFF04 float
declare @nCustoAtuFF05 float
declare @nQt2umFF      float
declare @nB2_CM1       decimal( 'B2_CM1' )
declare @nB2_CM2       decimal( 'B2_CM2' )
declare @nB2_CM3       decimal( 'B2_CM3' )
declare @nB2_CM4       decimal( 'B2_CM4' )
declare @nB2_CM5       decimal( 'B2_CM5' )
declare @nB9_CM1       decimal( 'B2_CM1' )
declare @nB9_CM2       decimal( 'B2_CM2' )
declare @nB9_CM3       decimal( 'B2_CM3' )
declare @nB9_CM4       decimal( 'B2_CM4' )
declare @nB9_CM5       decimal( 'B2_CM5' )
declare @nB9_CMRP1     decimal( 'B2_CM1' )
declare @nB9_CMRP2     decimal( 'B2_CM2' )
declare @nB9_CMRP3     decimal( 'B2_CM3' )
declare @nB9_CMRP4     decimal( 'B2_CM4' )
declare @nB9_CMRP5     decimal( 'B2_CM5' )
declare @nB9_VINIRP1   decimal( 'B2_VFIM1' )
declare @nB9_VINIRP2   decimal( 'B2_VFIM2' )
declare @nB9_VINIRP3   decimal( 'B2_VFIM3' )
declare @nB9_VINIRP4   decimal( 'B2_VFIM4' )
declare @nB9_VINIRP5   decimal( 'B2_VFIM5' )
declare @nB2_QFIM      decimal( 'B2_QFIM' )
declare @nB2_VFIM1     decimal( 'B2_VFIM1' )
declare @nB2_VFIM2     decimal( 'B2_VFIM2' )
declare @nB2_VFIM3     decimal( 'B2_VFIM3' )
declare @nB2_VFIM4     decimal( 'B2_VFIM4' )
declare @nB2_VFIM5     decimal( 'B2_VFIM5' )
declare @nB2_QFIM2     decimal( 'B2_QFIM2' )
declare @nB2_QFIMFF    decimal( 'B2_QFIMFF' )
declare @nB2_CMFF1     decimal( 'B2_CMFF1' )
declare @nB2_CMFF2     decimal( 'B2_CMFF2' )
declare @nB2_CMFF3     decimal( 'B2_CMFF3' )
declare @nB2_CMFF4     decimal( 'B2_CMFF4' )
declare @nB2_CMFF5     decimal( 'B2_CMFF5' )
declare @nB2_VFIMFF1   decimal( 'B2_VFIMFF1' )
declare @nB2_VFIMFF2   decimal( 'B2_VFIMFF2' )
declare @nB2_VFIMFF3   decimal( 'B2_VFIMFF3' )
declare @nB2_VFIMFF4   decimal( 'B2_VFIMFF4' )
declare @nB2_VFIMFF5   decimal( 'B2_VFIMFF5' )
declare @nTRB_VFIM1    decimal( 'B2_VFIM1' )
declare @nTRB_VFIM2    decimal( 'B2_VFIM2' )
declare @nTRB_VFIM3    decimal( 'B2_VFIM3' )
declare @nTRB_VFIM4    decimal( 'B2_VFIM4' )
declare @nTRB_VFIM5    decimal( 'B2_VFIM5' )
declare @nTRB_CM1      decimal( 'B2_CM1' )
declare @nTRB_CM2      decimal( 'B2_CM2' )
declare @nTRB_CM3      decimal( 'B2_CM3' )
declare @nTRB_CM4      decimal( 'B2_CM4' )
declare @nTRB_CM5      decimal( 'B2_CM5' )
declare @nCM1aux       decimal( 'B2_CM1' )
declare @nCM2aux       decimal( 'B2_CM2' )
declare @nCM3aux       decimal( 'B2_CM3' )
declare @nCM4aux       decimal( 'B2_CM4' )
declare @nCM5aux       decimal( 'B2_CM5' )
declare @nQTMOD		   decimal( 'B2_QFIM' )
declare @nTOTCM1       decimal( 'B2_CM1' )
declare @nRec          integer
declare @nRecAnt       integer
declare @nMaxRecnoSC2  integer
declare @iRecnoTRT     integer
declare @iRECNO_AUX    integer
declare @iTranCount    integer
declare @iPos          integer
declare @iRecno        integer
declare @nRecno        integer
declare @nCHKSB2	   integer
declare @cFILIALCOR    char('B1_FILIAL')
declare @dDTINICIO     char(08)
declare @cMV_PAR1      char(08)
declare @cMVULMES      char(08)
declare @cB1_CCCUSTO   char('B1_CCCUSTO')

begin

   /* -------------------------------------------------------------------------
    Evitando Parameter Sniffing
   ------------------------------------------------------------------------- */
   select @cFILIALCOR = @IN_FILIALCOR
   select @dDTINICIO = @IN_DINICIO
   select @cMV_PAR1 = @IN_MV_PAR1
   select @cMVULMES = @IN_MVULMES

  if @IN_CUSUNIF = '1' select @cCusFilAux = @IN_FILIALCOR
  else select @cCusFilAux = '  '
  /* --------------------------------------------------------------------------------------------
   Define inicio do processo
  -------------------------------------------------------------------------------------------- */
   select @OUT_RESULTADO = '0'
   select @cFILAUX       = @IN_CFILAUX
   if @cFILAUX is Null select @cFILAUX = '  '
   select @cB1_CC     = '0'
   select @nB2_QFIM   = 0
   select @nB2_CM1    = 0
   select @nB2_CM2    = 0
   select @nB2_CM3    = 0
   select @nB2_CM4    = 0
   select @nB2_CM5    = 0
   select @nB9_CM1    = 0
   select @nB9_CM2    = 0
   select @nB9_CM3    = 0
   select @nB9_CM4    = 0
   select @nB9_CM5    = 0
   select @nB9_CMRP1  = 0
   select @nB9_CMRP2  = 0
   select @nB9_CMRP3  = 0
   select @nB9_CMRP4  = 0
   select @nB9_CMRP5  = 0
   select @nB9_VINIRP1= 0
   select @nB9_VINIRP2= 0
   select @nB9_VINIRP3= 0
   select @nB9_VINIRP4= 0
   select @nB9_VINIRP5= 0
   select @nB2_QFIM2  = 0
   select @nB2_VFIM1  = 0
   select @nB2_VFIM2  = 0
   select @nB2_VFIM3  = 0
   select @nB2_VFIM4  = 0
   select @nB2_VFIM5  = 0
   select @nTRB_CM1   = 0
   select @nTRB_CM2   = 0
   select @nTRB_CM3   = 0
   select @nTRB_CM4   = 0
   select @nTRB_CM5   = 0
   select @cAux = 'SB1'
   EXEC XFILIAL_## @cAux, @cFILIALCOR, @cFil_SB1 OutPut
   select @cAux = 'SB2'
   EXEC XFILIAL_## @cAux, @cFILIALCOR, @cFil_SB2 OutPut
   select @cAux = 'SB9'
   EXEC XFILIAL_## @cAux, @cFILIALCOR, @cFil_SB9 OutPut
   select @cAux = 'SF4'
   EXEC XFILIAL_## @cAux, @cFILIALCOR, @cFil_SF4 OutPut
   select @cAux = 'SC2'
   EXEC XFILIAL_## @cAux, @cFILIALCOR, @cFil_SC2 OutPut
   select @cAux = 'SD1'
   EXEC XFILIAL_## @cAux, @cFILIALCOR, @cFil_SD1 OutPut
   select @cAux = 'SD2'
   EXEC XFILIAL_## @cAux, @cFILIALCOR, @cFil_SD2 OutPut
   select @cAux = 'SD3'
   EXEC XFILIAL_## @cAux, @cFILIALCOR, @cFil_SD3 OutPut
   select @cCodOriMod = ' '
   select @cFiltra = '0'

   /* -------------------------------------------------------------------------
    Cursor no SB2 Selecionando todos produtos de acordo filial corrente
   ------------------------------------------------------------------------- */
     declare CUR_A330INI INSENSITIVE cursor for
       select SB2.B2_FILIAL, SB2.B2_COD  , SB2.B2_LOCAL, SB2.R_E_C_N_O_,
              SB2.B2_QFIM  , SB2.B2_VFIM1, SB2.B2_VFIM2, SB2.B2_VFIM3, SB2.B2_VFIM4, SB2.B2_VFIM5,
              SB2.B2_QFIM2 , SB2.B2_CM1  , SB2.B2_CM2  , SB2.B2_CM3  , SB2.B2_CM4  , SB2.B2_CM5,
              SB1.B1_CCCUSTO
         from SB2### SB2 (nolock), SB1### SB1 (nolock)
        where SB2.B2_FILIAL  = @cFil_SB2
          and SB1.B1_FILIAL  = @cFil_SB1
          and SB2.B2_COD     = SB1.B1_COD
          and SB2.D_E_L_E_T_ = ' '
          and SB1.D_E_L_E_T_ = ' '
          ##IF_001({|| !SuperGetMV('MV_A330GRV',.F.,.T.) })
                 and (     SB2.B2_QFIM  <> 0
                        or SB2.B2_VFIM1 <> 0
                        or SB2.B2_VFIM2 <> 0
                        or SB2.B2_VFIM3 <> 0
                        or SB2.B2_VFIM4 <> 0
                        or SB2.B2_VFIM5 <> 0
                        or (substring(SB1.B1_COD, 1, 3) = 'MOD' or SB1.B1_CCCUSTO <> ' ')
                        or exists (select 1
                                     from SB9### SB9 (nolock)
                                        where SB9.B9_FILIAL = @cFil_SB9
                                          and SB9.B9_COD    = SB2.B2_COD
                                          and SB9.B9_LOCAL  = SB2.B2_LOCAL
                                          and (SB9.B9_DATA   = @cMVULMES or SB9.B9_DATA = ' ')
                                          and SB9.D_E_L_E_T_ = ' '
                                          and (SB9.B9_QINI  <> 0
                                            or SB9.B9_VINI1 <> 0
                                            or SB9.B9_VINI2 <> 0
                                            or SB9.B9_VINI3 <> 0
                                            or SB9.B9_VINI4 <> 0
                                            or SB9.B9_VINI5 <> 0) )
                       or exists (select 1
                                     from SD1### SD1 (nolock), SF4### SF4 (nolock)
                                    where SD1.D1_FILIAL  = @cFil_SD1
                                      and SD1.D1_COD     = SB2.B2_COD
                                      and SD1.D1_LOCAL   = SB2.B2_LOCAL
                                      and SD1.D1_DTDIGIT > (select Convert(Char(08), dateadd(day,1,max(B9_DATA)), 112)
                                                              from SB9###
                                                             where B9_FILIAL = @cFil_SB9
                                                               and B9_COD    = SD1.D1_COD
                                                               and B9_LOCAL  = SD1.D1_LOCAL
                                                               and B9_DATA   < @dDTINICIO
                                                               and D_E_L_E_T_ =  ' ')
                                      and SD1.D1_DTDIGIT <= @cMV_PAR1
                                      and SD1.D1_ORIGLAN <> 'LF'
                                      and SF4.F4_FILIAL  = @cFil_SF4
                                      and SF4.F4_CODIGO  = SD1.D1_TES
                                      and SF4.F4_ESTOQUE = 'S'
                                      and SF4.D_E_L_E_T_ = ' '
                                      and SD1.D_E_L_E_T_ = ' ' )
                        or exists (select 1
                                     from SD2### SD2 (nolock), SF4### SF4 (nolock)
                                    where SD2.D2_FILIAL  = @cFil_SD2
                                      and SD2.D2_COD     = SB2.B2_COD
                                      and SD2.D2_LOCAL   = SB2.B2_LOCAL
                                      and SD2.D2_EMISSAO > (select Convert(Char(08), dateadd(day,1,max(B9_DATA)), 112)
                                                              from SB9###
                                                             where B9_FILIAL = @cFil_SB9
                                                               and B9_COD    = SD2.D2_COD
                                                               and B9_LOCAL  = SD2.D2_LOCAL
                                                               and B9_DATA   < @dDTINICIO
                                                               and D_E_L_E_T_ =  ' ')
                                      and SD2.D2_EMISSAO <= @cMV_PAR1
                                      and SD2.D2_ORIGLAN <> 'LF'
                                      and SF4.F4_FILIAL  = @cFil_SF4
                                      and SF4.F4_CODIGO  = SD2.D2_TES
                                      and SF4.F4_ESTOQUE = 'S'
                                      and SF4.D_E_L_E_T_ = ' '
                                      and SD2.D_E_L_E_T_ = ' ' )
                        or exists (select 1
                                     from SD3### SD3 (nolock)
                                    where SD3.D3_FILIAL  = @cFil_SD3
                                      and SD3.D3_COD     = SB2.B2_COD
                                      and SD3.D3_LOCAL   = SB2.B2_LOCAL
                                      and SD3.D3_EMISSAO > (select Convert(Char(08), dateadd(day,1,max(B9_DATA)), 112)
                                                              from SB9###
                                                             where B9_FILIAL = @cFil_SB9
                                                               and B9_COD    = SD3.D3_COD
                                                               and B9_LOCAL  = SD3.D3_LOCAL
                                                               and B9_DATA   < @dDTINICIO
                                                               and D_E_L_E_T_ =  ' ')

                                      and SD3.D3_EMISSAO <= @cMV_PAR1
                                      and SD3.D3_ESTORNO = ' '
                                      and SD3.D_E_L_E_T_ = ' ' )
                 )
         ##ENDIF_001
     order by SB2.B2_FILIAL, SB2.B2_COD, SB2.B2_LOCAL
     for read only
     open  CUR_A330INI
     fetch CUR_A330INI into @cFil_SB2 , @cCod     , @cLocal   , @nRecno   , @nB2_QFIM ,
                            @nB2_VFIM1, @nB2_VFIM2, @nB2_VFIM3, @nB2_VFIM4, @nB2_VFIM5,
                            @nB2_QFIM2, @nB2_CM1  , @nB2_CM2  , @nB2_CM3  , @nB2_CM4  ,
                            @nB2_CM5  , @cB1_CCCUSTO
   while (@@fetch_status = 0) begin
/*  ---------------------------------------------------------------------------------------------------------------
         Tratamento para desconsiderar o produto MANUTECAO integracao com SIGAMNT
    --------------------------------------------------------------------------------------------------------------- */
      If @IN_MV_PRODMNT = @cCod Begin
/*       ------------------------------------------------------------------------------------------------------
           Tratamento para o DB2
         ------------------------------------------------------------------------------------------------------ */
         SELECT @fim_CUR = 0
         fetch CUR_A330INI into @cFil_SB2  , @cCod     , @cLocal  , @nRecno  , @nB2_QFIM , @nB2_VFIM1 , @nB2_VFIM2 , @nB2_VFIM3 , @nB2_VFIM4,
                                 @nB2_VFIM5, @nB2_QFIM2, @nB2_CM1 , @nB2_CM2 , @nB2_CM3  , @nB2_CM4   , @nB2_CM5   , @cB1_CCCUSTO
         continue
      End
/*    ---------------------------------------------------------------------------------------------------------------
         Verifica se utiliza mao-de-obra atraves do campo B1_CCCUSTO
      --------------------------------------------------------------------------------------------------------------- */

      If @cB1_CCCUSTO = ' ' begin
         select @cB1_CC = '0'
      End Else begin
	      select @cB1_CC = '1'
      End

/*    ---------------------------------------------------------------------------------------------------------------
         Verifica se filtra armazem de acordo com o ponto de entrada
      --------------------------------------------------------------------------------------------------------------- */
      select @cFiltra = '0'
      exec MA330AL_## @cFILIALCOR, @cCod, @cLocal, @nRecno, @cFiltra output
      if @cFiltra = '1' begin
/*       ------------------------------------------------------------------------------------------------------
           Tratamento para o DB2
         ------------------------------------------------------------------------------------------------------ */
        SELECT @fim_CUR = 0
        fetch CUR_A330INI into @cFil_SB2 , @cCod     , @cLocal  , @nRecno  , @nB2_QFIM , @nB2_VFIM1 , @nB2_VFIM2 , @nB2_VFIM3 , @nB2_VFIM4,
                               @nB2_VFIM5, @nB2_QFIM2, @nB2_CM1 , @nB2_CM2 , @nB2_CM3  , @nB2_CM4   , @nB2_CM5   , @cB1_CCCUSTO
        continue
      end
      select @nTRB_VFIM1 = 0
      select @nTRB_VFIM2 = 0
      select @nTRB_VFIM3 = 0
      select @nTRB_VFIM4 = 0
      select @nTRB_VFIM5 = 0
      select @nTRB_QFIM  = 0
      select @nVFim01    = 0
      select @nVFim02    = 0
      select @nVFim03    = 0
      select @nVFim04    = 0
      select @nVFim05    = 0
      select @nQFim01    = 0
      select @nQFim02    = 0
      select @nQFim03    = 0
      select @nQFim04    = 0
      select @nQFim05    = 0
      select @nB9_CM1    = 0
      select @nB9_CM2    = 0
      select @nB9_CM3    = 0
      select @nB9_CM4    = 0
      select @nB9_CM5    = 0
      select @nB9_CMRP1  = 0
      select @nB9_CMRP2  = 0
      select @nB9_CMRP3  = 0
      select @nB9_CMRP4  = 0
      select @nB9_CMRP5  = 0
      select @nB9_VINIRP1= 0
      select @nB9_VINIRP2= 0
      select @nB9_VINIRP3= 0
      select @nB9_VINIRP4= 0
      select @nB9_VINIRP5= 0
      select @cLocalOri  = @cLocal

      if (@IN_MV_PRODMOD = '0' and @cB1_CCCUSTO <> ' ') or ((substring( @cCod, 1, 3 ) <> 'MOD') and isnull(@cB1_CC, '0') = '0')  begin
/*       ------------------------------------------------------------------------------------------------------------
            Recupera Saldos Iniciais SB9, SD1 ,SD2 e SD3 pela funcao calcest()- "MTXFUN1"
         ------------------------------------------------------------------------------------------------------------- */
         exec MAT006_## @cCod, 			@cLocal,		@dDTINICIO,	@cFILAUX,	@IN_MV_LOCPROC,
                        @cFILIALCOR,	@IN_MV_D3SERVI,	@IN_INTDL,		@IN_MV_CQ,	@IN_MV_WMSNEW,
						'0',
                        @nSaldo01    output, @nSaldo02    output, @nSaldo03    output, @nSaldo04    output,
                        @nSaldo05    output, @nSaldo06    output, @nSaldo07    output, @nB9_CM1     output,
                        @nB9_CM2     output, @nB9_CM3     output, @nB9_CM4     output, @nB9_CM5     output,
                        @nB9_CMRP1   output, @nB9_CMRP2   output, @nB9_CMRP3   output, @nB9_CMRP4   output,
                        @nB9_CMRP5   output, @nB9_VINIRP1 output, @nB9_VINIRP2 output, @nB9_VINIRP3 output,
                        @nB9_VINIRP4 output, @nB9_VINIRP5 output

         if @IN_CUSUNIF in ('1','2') begin
            If @cCod <> @cCodOriMod begin
               select @cCodOriMod = @cCod
            end
         end else  select @cCodOriMod = ' '

      end else begin

         if substring(@IN_COPCOES, 1, 1) = '1' begin
            select @cCodOriMod = ' '
            select @nSaldo01 = @nB2_QFIM
            select @nSaldo02 = @nB2_VFIM1
            select @nSaldo03 = @nB2_VFIM2
            select @nSaldo04 = @nB2_VFIM3
            select @nSaldo05 = @nB2_VFIM4
            select @nSaldo06 = @nB2_VFIM5
            select @nSaldo07 = @nB2_QFIM2
         end else begin
            if @IN_CUSUNIF in ('1','2') begin
               If @cCod <> @cCodOriMod begin
                  select @cCodOriMod = @cCod
               end
            end else select @cCodOriMod = ' '
            select @nSaldo01 = 0
            select @nSaldo02 = 0
            select @nSaldo03 = 0
            select @nSaldo04 = 0
            select @nSaldo05 = 0
            select @nSaldo06 = 0
            select @nSaldo07 = 0
         end
      end
      select @nSaldo01 = isnull(@nSaldo01,0)
      select @nSaldo02 = isnull(@nSaldo02,0)
      select @nSaldo03 = isnull(@nSaldo03,0)
      select @nSaldo04 = isnull(@nSaldo04,0)
      select @nSaldo05 = isnull(@nSaldo05,0)
      select @nSaldo06 = isnull(@nSaldo06,0)
      select @nSaldo07 = isnull(@nSaldo07,0)
      select @nB9_CM1 = isnull(@nB9_CM1,0)
      select @nB9_CM2 = isnull(@nB9_CM2,0)
      select @nB9_CM3 = isnull(@nB9_CM3,0)
      select @nB9_CM4 = isnull(@nB9_CM4,0)
      select @nB9_CM5 = isnull(@nB9_CM5,0)
      select @nB9_CMRP1 = isnull(@nB9_CMRP1,0)
      select @nB9_CMRP2 = isnull(@nB9_CMRP2,0)
      select @nB9_CMRP3 = isnull(@nB9_CMRP3,0)
      select @nB9_CMRP4 = isnull(@nB9_CMRP4,0)
      select @nB9_CMRP5 = isnull(@nB9_CMRP5,0)
      select @nB9_VINIRP1 = isnull(@nB9_VINIRP1,0)
      select @nB9_VINIRP2 = isnull(@nB9_VINIRP2,0)
      select @nB9_VINIRP3 = isnull(@nB9_VINIRP3,0)
      select @nB9_VINIRP4 = isnull(@nB9_VINIRP4,0)
      select @nB9_VINIRP5 = isnull(@nB9_VINIRP5,0)

      if (@nSaldo01 > 0) begin
/*       -----------------------------------------------------------------------------------------------------------
            O código abaixo foi criado para tratar a gravação dos custos. Quando o valor final estiver negativo ou
            igual a zero é gravado o mesmo conteúdo campo, ou seja, a operação não tem efeito nenhum.
         ------------------------------------------------------------------------------------------------------------ */
         select @nVFim01 = @nSaldo02
         select @nVFim02 = @nSaldo03
         select @nVFim03 = @nSaldo04
         select @nVFim04 = @nSaldo05
         select @nVFim05 = @nSaldo06
         select @nQFim01 = @nSaldo01
         select @nQFim02 = @nSaldo01
         select @nQFim03 = @nSaldo01
         select @nQFim04 = @nSaldo01
         select @nQFim05 = @nSaldo01
         if @nVFim01 <= 0 begin
            select @nVFim01 = isnull(@nB2_CM1,0)
            if (substring( @cCod, 1, 3 ) <> 'MOD') and isnull(@cB1_CC, '0') = '0'  select @nVFim01 = isnull(@nB9_CM1,0)
            select @nQFim01 = 1
         end
         if @nVFim02 <= 0 begin
            select @nVFim02 = isnull(@nB2_CM2,0)
            if (substring( @cCod, 1, 3 ) <> 'MOD') and isnull(@cB1_CC, '0') = '0'  select @nVFim02 = isnull(@nB9_CM2,0)
            select @nQFim02 = 1
         end
         if @nVFim03 <= 0 begin
            select @nVFim03 = isnull(@nB2_CM3,0)
            if (substring( @cCod, 1, 3 ) <> 'MOD') and isnull(@cB1_CC, '0') = '0'  select @nVFim03 = isnull(@nB9_CM3,0)
            select @nQFim03 = 1
         end
         if @nVFim04 <= 0 begin
            select @nVFim04 = isnull(@nB2_CM4,0)
            if (substring( @cCod, 1, 3 ) <> 'MOD') and isnull(@cB1_CC, '0') = '0'  select @nVFim04 = isnull(@nB9_CM4,0)
            select @nQFim04   = 1
         end
         if @nVFim05 <= 0 begin
            select @nVFim05 = isnull(@nB2_CM5,0)
            if (substring( @cCod, 1, 3 ) <> 'MOD') and isnull(@cB1_CC, '0') = '0'  select @nVFim05 = isnull(@nB9_CM5,0)
            select @nQFim05 = 1
         end
         if @nQFim01 = 0 begin
            select @nQFim01 = 1
         end
         if @nQFim02 = 0 begin
            select @nQFim02 = 1
         end
         if @nQFim03 = 0 begin
            select @nQFim03 = 1
         end
         if @nQFim04 = 0 begin
            select @nQFim04 = 1
         end
         if @nQFim05 = 0 begin
            select @nQFim05 = 1
         end
         select @nB2_CM1 = @nVFim01 / @nQFim01
         select @iPos = Charindex( '2', @IN_MV_MOEDACM )
         If @iPos > 0 begin
            select @nB2_CM2 = @nVFim02 / @nQFim02
         End
         select @iPos = Charindex( '3', @IN_MV_MOEDACM )
         If @iPos > 0 begin
            select @nB2_CM3 = @nVFim03 / @nQFim03
         End
         select @iPos = Charindex( '4', @IN_MV_MOEDACM )
         If @iPos > 0 begin
            select @nB2_CM4 = @nVFim04 / @nQFim04
         End
         select @iPos = Charindex( '5', @IN_MV_MOEDACM )
         If @iPos > 0 begin
            select @nB2_CM5 = @nVFim05 / @nQFim05
         End
         begin transaction
         update SB2###
            set B2_QFIM = @nSaldo01, B2_VFIM1 = @nSaldo02,
                B2_CMFIM1 = @nB2_CM1,  B2_QFIM2 = @nSaldo07
                ##FIELDP01( 'SB9.B9_CMRP1;SB9.B9_VINIRP1')
                  ,B2_CMRP1= @nB9_CMRP1, B2_VFRP1 = @nB9_VINIRP1
                ##ENDFIELDP01
          where R_E_C_N_O_ = @nRecno
         select @iPos = Charindex( '2', @IN_MV_MOEDACM )
         If @iPos > 0 begin
             update SB2###
                set B2_VFIM2 = @nSaldo03, B2_CMFIM2 = @nB2_CM2
                ##FIELDP02( 'SB9.B9_CMRP2;SB9.B9_VINIRP2' )
                  ,B2_CMRP2= @nB9_CMRP2, B2_VFRP2 = @nB9_VINIRP2
                ##ENDFIELDP02
              where R_E_C_N_O_ = @nRecno
          End
         select @iPos = Charindex( '3', @IN_MV_MOEDACM )
         If @iPos > 0 begin
             update SB2###
                set B2_VFIM3 = @nSaldo04, B2_CMFIM3 = @nB2_CM3
                ##FIELDP03( 'SB9.B9_CMRP3;SB9.B9_VINIRP3' )
                ,B2_CMRP3= @nB9_CMRP3, B2_VFRP3 = @nB9_VINIRP3
                ##ENDFIELDP03
              where R_E_C_N_O_ = @nRecno
          End
         select @iPos = Charindex( '4', @IN_MV_MOEDACM )
         If @iPos > 0 begin
             update SB2###
                set B2_VFIM4 = @nSaldo05, B2_CMFIM4 = @nB2_CM4
                ##FIELDP04( 'SB9.B9_CMRP4;SB9.B9_VINIRP4' )
                  ,B2_CMRP4= @nB9_CMRP4, B2_VFRP4 = @nB9_VINIRP4
                ##ENDFIELDP04
              where R_E_C_N_O_ = @nRecno
          End
         select @iPos = Charindex( '5', @IN_MV_MOEDACM )
         If @iPos > 0 begin
             update SB2###
                set B2_VFIM5 = @nSaldo06, B2_CMFIM5 = @nB2_CM5
                ##FIELDP05( 'SB9.B9_CMRP5;SB9.B9_VINIRP5' )
                  ,B2_CMRP5= @nB9_CMRP5, B2_VFRP5 = @nB9_VINIRP5
                ##ENDFIELDP05
              where R_E_C_N_O_ = @nRecno
          End
         commit transaction
      end else begin
         begin transaction
         if (substring( @cCod, 1, 3 ) <> 'MOD') and isnull(@cB1_CC, '0') = '0'  begin
            update SB2###
               set B2_QFIM   = @nSaldo01, B2_VFIM1 = @nSaldo02,
                   B2_QFIM2  = @nSaldo07
                   ##FIELDP06( 'SB9.B9_CM1' )
                    , B2_CMFIM1 = @nB9_CM1
                   ##ENDFIELDP06
                   ##FIELDP07( 'SB9.B9_CMRP1;SB9.B9_VINIRP1' )
                   , B2_CMRP1= @nB9_CMRP1, B2_VFRP1 = @nB9_VINIRP1
                   ##ENDFIELDP07
              where R_E_C_N_O_ = @nRecno
         end else begin
            update SB2###
               set B2_QFIM = @nSaldo01, B2_VFIM1 = @nSaldo02,
                   B2_QFIM2 = @nSaldo07
              where R_E_C_N_O_ = @nRecno
         end
         select @iPos = Charindex( '2', @IN_MV_MOEDACM )
         If @iPos > 0 begin
            if (substring( @cCod, 1, 3 ) <> 'MOD') and isnull(@cB1_CC, '0') = '0'  begin
               update SB2###
                  set B2_VFIM2  = @nSaldo03, B2_CMFIM2 = @nB9_CM2
                      ##FIELDP08( 'SB9.B9_CMRP2;SB9.B9_VINIRP2' )
                      , B2_CMRP2= @nB9_CMRP2, B2_VFRP2 = @nB9_VINIRP2
                      ##ENDFIELDP08
               where R_E_C_N_O_ = @nRecno
             end else begin
               update SB2###
                  set B2_VFIM2  = @nSaldo03
               where R_E_C_N_O_ = @nRecno
             end
          End
         select @iPos = Charindex( '3', @IN_MV_MOEDACM )
         If @iPos > 0 begin
            if (substring( @cCod, 1, 3 ) <> 'MOD') and isnull(@cB1_CC, '0') = '0'  begin
               update SB2###
                  set B2_VFIM3 = @nSaldo04, B2_CMFIM3 = @nB9_CM3
                      ##FIELDP09( 'SB9.B9_CMRP3;SB9.B9_VINIRP3' )
                      , B2_CMRP3= @nB9_CMRP3, B2_VFRP3 = @nB9_VINIRP3
                      ##ENDFIELDP09
                where R_E_C_N_O_ = @nRecno
            end else begin
               update SB2###
                  set B2_VFIM3 = @nSaldo04
                where R_E_C_N_O_ = @nRecno
            end
          End
         select @iPos = Charindex( '4', @IN_MV_MOEDACM )
         If @iPos > 0 begin
            if (substring( @cCod, 1, 3 ) <> 'MOD') and isnull(@cB1_CC, '0') = '0'  begin
               update SB2###
                  set B2_VFIM4  = @nSaldo05, B2_CMFIM4 = @nB9_CM4
                  ##FIELDP10( 'SB9.B9_CMRP4;SB9.B9_VINIRP4' )
                  , B2_CMRP4= @nB9_CMRP4, B2_VFRP4 = @nB9_VINIRP4
                  ##ENDFIELDP10
               where R_E_C_N_O_ = @nRecno
            end else begin
               update SB2###
                  set B2_VFIM4  = @nSaldo05
               where R_E_C_N_O_ = @nRecno
            end
          End
         select @iPos = Charindex( '5', @IN_MV_MOEDACM )
         If @iPos > 0 begin
            if (substring( @cCod, 1, 3 ) <> 'MOD') and isnull(@cB1_CC, '0') = '0'  begin
               update SB2###
                  set B2_VFIM5 = @nSaldo06, B2_CMFIM5 = @nB9_CM5
                  ##FIELDP11( 'SB9.B9_CMRP5;SB9.B9_VINIRP5' )
                  , B2_CMRP5= @nB9_CMRP5, B2_VFRP5 = @nB9_VINIRP5
                  ##ENDFIELDP11
               where R_E_C_N_O_ = @nRecno
            end else begin
               update SB2###
                  set B2_VFIM5 = @nSaldo06
               where R_E_C_N_O_ = @nRecno
            end
          End
          if (substring( @cCod, 1, 3 ) <> 'MOD') and isnull(@cB1_CC, '0') = '0'  begin
            select @nB2_CM1 = @nB9_CM1
            select @nB2_CM2 = @nB9_CM2
            select @nB2_CM3 = @nB9_CM3
            select @nB2_CM4 = @nB9_CM4
            select @nB2_CM5 = @nB9_CM5
          end
         commit transaction
      end
/*    ---------------------------------------------------------------------------------------------------------------
         Arquivo de Trabalho para custo unificado "TRT"
      --------------------------------------------------------------------------------------------------------------- */
      if @IN_CUSUNIF in ('1','2') begin
         select @iRecnoTRT = 0
         select @iRecnoTRT = isnull( R_E_C_N_O_, 0), @nTRB_QFIM = TRB_QFIM
           from TRT### (nolock)
          where TRB_FILIAL = @cCusFilAux
            AND TRB_COD = @cCod
/*       ------------------------------------------------------------------------------------------------------------
            Insere registro no arquivo TRT
         ------------------------------------------------------------------------------------------------------------ */
         if isnull(@iRecnoTRT,0) = 0 begin
			insert into TRT### ( TRB_FILIAL, TRB_COD )
                        values ( @cCusFilAux, @cCod )

            SELECT @iRecnoTRT  =  MAX ( R_E_C_N_O_ )
              FROM TRT###
              WHERE TRB_FILIAL  = @cCusFilAux and TRB_COD = @cCod

         end
/*       ------------------------------------------------------------------------------------------------------------
            Atualizando arquivo de trabalho
         ------------------------------------------------------------------------------------------------------------ */
         if (substring(@cCod, 1, 3) <> 'MOD') and isnull(@cB1_CC, '0') = '0'  begin
            select @nCHKSB2 = R_E_C_N_O_
                 from SB2### (nolock)
                where B2_FILIAL = @cCusFilAux
                and B2_COD = @cCod
                and B2_LOCAL = @cLocal
                and B2_QATU = 0
                and B2_CMFIM1 = 0
                and D_E_L_E_T_ = ' '
            if isnull(@nCHKSB2,0) > 0 begin
                select @nQTMOD = TRB_QTDMOD, @nTOTCM1 = TRB_TOTCM1
                from TRT### (nolock)
                where R_E_C_N_O_ = @iRecnoTRT

                if @nQTMOD > 0 and @nB2_CM1 = 0 begin
                    Select @nB2_CM1 = @nTOTCM1 / @nQTMOD
                End
            End
            Update TRT###
               set TRB_QFIM  = TRB_QFIM + @nSaldo01,
                   TRB_QFIM2 = TRB_QFIM2 + @nSaldo07,
                   TRB_VFIM1 = TRB_VFIM1 + @nSaldo02,
                   TRB_QTDMOD = TRB_QTDMOD + 1,
                   TRB_TOTCM1 = TRB_TOTCM1 + @nB2_CM1
             where R_E_C_N_O_ = @iRecnoTRT
            select @nTRB_QFIM = TRB_QFIM, @nTRB_VFIM1 = TRB_VFIM1
              from TRT###
              where R_E_C_N_O_ = @iRecnoTRT
            select @iPos = Charindex( '2', @IN_MV_MOEDACM )
            If @iPos > 0 begin
               Update TRT###
                  set TRB_VFIM2 = TRB_VFIM2   + @nSaldo03,
                      TRB_TOTCM2 = TRB_TOTCM2 + @nB2_CM2
                where R_E_C_N_O_ = @iRecnoTRT
               select @nTRB_VFIM2 = TRB_VFIM2
                 from TRT###
                where R_E_C_N_O_ = @iRecnoTRT
            End
            select @iPos = Charindex( '3', @IN_MV_MOEDACM )
            If @iPos > 0 begin
               Update TRT###
                  set TRB_VFIM3 = TRB_VFIM3   + @nSaldo04,
                      TRB_TOTCM3 = TRB_TOTCM3 + @nB2_CM3
                where R_E_C_N_O_ = @iRecnoTRT
               select @nTRB_VFIM3 = TRB_VFIM3
                 from TRT###
                 where R_E_C_N_O_ = @iRecnoTRT
            End
            select @iPos = Charindex( '4', @IN_MV_MOEDACM )
            If @iPos > 0 begin
               Update TRT###
                  set TRB_VFIM4 = TRB_VFIM4 + @nSaldo05,
                      TRB_TOTCM4 = TRB_TOTCM4 + @nB2_CM4
                where R_E_C_N_O_ = @iRecnoTRT
               select @nTRB_VFIM4 = TRB_VFIM4
                 from TRT###
                where R_E_C_N_O_ = @iRecnoTRT
            End
            select @iPos = Charindex( '5', @IN_MV_MOEDACM )
            If @iPos > 0 begin
               Update TRT###
                  set TRB_VFIM5 = TRB_VFIM5 + @nSaldo06,
                      TRB_TOTCM5 = TRB_TOTCM5 + @nB2_CM5
                where R_E_C_N_O_ = @iRecnoTRT
               select @nTRB_VFIM5 = TRB_VFIM5
                 from TRT###
                where R_E_C_N_O_ = @iRecnoTRT
            End
         end
         if (substring(@cCod, 1, 3) <> 'MOD') and isnull(@cB1_CC, '0') = '0'  begin
            If @nTRB_VFIM1 > 0 and @nTRB_QFIM > 0
               Update TRT###
                  set TRB_CM1 = TRB_VFIM1 / @nTRB_QFIM
                where R_E_C_N_O_ = @iRecnoTRT
            else
               Update TRT###
                  set TRB_CM1 = TRB_TOTCM1 / TRB_QTDMOD
                where R_E_C_N_O_ = @iRecnoTRT
            select @iPos = Charindex( '2', @IN_MV_MOEDACM )
            If @iPos > 0 begin
               If @nTRB_VFIM2 > 0 and @nTRB_QFIM > 0
                  Update TRT###
                     set TRB_CM2 = TRB_VFIM2 / @nTRB_QFIM
                   where R_E_C_N_O_ = @iRecnoTRT
               else
                  Update TRT###
                     set TRB_CM2 = TRB_TOTCM2 / TRB_QTDMOD
                   where R_E_C_N_O_ = @iRecnoTRT
            End
            select @iPos = Charindex( '3', @IN_MV_MOEDACM )
            If @iPos > 0 begin
               If @nTRB_VFIM3 > 0 and @nTRB_QFIM > 0
                  Update TRT###
                     set TRB_CM3 = TRB_VFIM3 / @nTRB_QFIM
                   where R_E_C_N_O_ = @iRecnoTRT
               else
                  Update TRT###
                     set TRB_CM3 = TRB_TOTCM3 / TRB_QTDMOD
                   where R_E_C_N_O_ = @iRecnoTRT
            End
            select @iPos = Charindex( '4', @IN_MV_MOEDACM )
            If @iPos > 0 begin
               If @nTRB_VFIM4 > 0 and @nTRB_QFIM > 0
                  Update TRT###
                     set TRB_CM4 = TRB_VFIM4 / @nTRB_QFIM
                   where R_E_C_N_O_ = @iRecnoTRT
               else
                  Update TRT###
                     set TRB_CM4 = TRB_TOTCM4 / TRB_QTDMOD
                   where R_E_C_N_O_ = @iRecnoTRT
            End
            select @iPos = Charindex( '5', @IN_MV_MOEDACM )
            If @iPos > 0 begin
               If @nTRB_VFIM5 > 0 and @nTRB_QFIM > 0
                  Update TRT###
                     set TRB_CM5 = TRB_VFIM5 / @nTRB_QFIM
                   where R_E_C_N_O_ = @iRecnoTRT
               else
                  Update TRT###
                     set TRB_CM5 = TRB_TOTCM5 / TRB_QTDMOD
                   where R_E_C_N_O_ = @iRecnoTRT
            End
         end else if (substring(@IN_COPCOES, 1, 1) <> '1') begin
            Update TRT###
               set TRB_QTDMOD = TRB_QTDMOD + 1,
                   TRB_TOTCM1 = TRB_TOTCM1 + @nB2_CM1
             where R_E_C_N_O_ = @iRecnoTRT
            Update TRT###
               set TRB_CM1 = TRB_TOTCM1 / TRB_QTDMOD
             where R_E_C_N_O_ = @iRecnoTRT
            select @iPos = Charindex( '2', @IN_MV_MOEDACM )
            If @iPos > 0 begin
              Update TRT###
                 set TRB_TOTCM2 = TRB_TOTCM2 + @nB2_CM2
               where R_E_C_N_O_ = @iRecnoTRT
              Update TRT###
                 set TRB_CM2 = TRB_TOTCM2 / TRB_QTDMOD
               where R_E_C_N_O_ = @iRecnoTRT
            End
            select @iPos = Charindex( '3', @IN_MV_MOEDACM )
            If @iPos > 0 begin
              Update TRT###
                 set TRB_TOTCM3 = TRB_TOTCM3 + @nB2_CM3
               where R_E_C_N_O_ = @iRecnoTRT
              Update TRT###
                 set TRB_CM3 = TRB_TOTCM3 / TRB_QTDMOD
               where R_E_C_N_O_ = @iRecnoTRT
            End
            select @iPos = Charindex( '4', @IN_MV_MOEDACM )
            If @iPos > 0 begin
              Update TRT###
                 set TRB_TOTCM4 = TRB_TOTCM4 + @nB2_CM4
               where R_E_C_N_O_ = @iRecnoTRT
              Update TRT###
                 set TRB_CM4 = TRB_TOTCM4 / TRB_QTDMOD
               where R_E_C_N_O_ = @iRecnoTRT
            End
            select @iPos = Charindex( '5', @IN_MV_MOEDACM )
            If @iPos > 0 begin
              Update TRT###
               set TRB_TOTCM5 = TRB_TOTCM5 + @nB2_CM5
               where R_E_C_N_O_ = @iRecnoTRT
              Update TRT###
                 set TRB_CM5 = TRB_TOTCM5 / TRB_QTDMOD
               where R_E_C_N_O_ = @iRecnoTRT
            End
         End
      End
/*    ---------------------------------------------------------------------------------------------------------------
         Gravar os Valores finais no SB2 com o CUSTO EM PARTES.
      --------------------------------------------------------------------------------------------------------------- */
      exec M330INB2CP_## @cFILIALCOR, @dDTINICIO, @IN_CUSUNIF, @cCod, @cLocal, @nRecno
/*    ---------------------------------------------------------------------------------------------------------------
         Custo Fifo / Lifo
      --------------------------------------------------------------------------------------------------------------- */
      ##FIELDP12( 'SCC.CC_SEQ' )
      If @IN_MV_CUSFIFO = '1' begin
        exec MAT049_## @cCod,                 @cLocal,               @dDTINICIO,           @cFILIALCOR,
                       @nQSaldoAtuFF  OutPut, @nCustoAtuFF01 OutPut, @nCustoAtuFF02 OutPut, @nCustoAtuFF03 OutPut,
                       @nCustoAtuFF04 OutPut, @nCustoAtuFF05 OutPut, @nQt2umFF OutPut
        select @nB2_QFIMFF = @nQSaldoAtuFF
        select @nB2_VFIMFF1 = 0
        select @nB2_VFIMFF2 = 0
        select @nB2_VFIMFF3 = 0
        select @nB2_VFIMFF4 = 0
        select @nB2_VFIMFF5 = 0
        select @nB2_CMFF1   = 0
        select @nB2_CMFF2   = 0
        select @nB2_CMFF3   = 0
        select @nB2_CMFF4   = 0
        select @nB2_CMFF5   = 0
        select @nB2_VFIMFF1 = @nCustoAtuFF01
        if (@nSaldo01 > 0) and (@nCustoAtuFF01 > 0) begin
            select @nB2_CMFF1 = @nB2_VFIMFF1 / @nSaldo01
        end
        select @iPos = Charindex( '2', @IN_MV_MOEDACM )
        If @iPos > 0 begin
           select @nB2_VFIMFF2 = @nCustoAtuFF02
           if (@nSaldo01 > 0) and (@nB2_VFIMFF2 > 0)begin
              select @nB2_CMFF2 = @nB2_VFIMFF2 / @nSaldo01
           end
        End
        select @iPos = Charindex( '3', @IN_MV_MOEDACM )
        If @iPos > 0 begin
           select @nB2_VFIMFF3 = @nCustoAtuFF03
           if (@nSaldo01 > 0) and (@nB2_VFIMFF3 > 0)begin
              select @nB2_CMFF3 = @nB2_VFIMFF3 / @nSaldo01
           end
        End
        select @iPos = Charindex( '4', @IN_MV_MOEDACM )
        If @iPos > 0 begin
           select @nB2_VFIMFF4 = @nCustoAtuFF04
           if (@nSaldo01 > 0) and (@nB2_VFIMFF4 > 0)begin
              select @nB2_CMFF4 = @nB2_VFIMFF4 / @nSaldo01
           end
        End
        select @iPos = Charindex( '5', @IN_MV_MOEDACM )
        If @iPos > 0 begin
           select @nB2_VFIMFF5 = @nCustoAtuFF05
           if (@nSaldo01 > 0) and (@nB2_VFIMFF5 > 0)begin
              select @nB2_CMFF5 = @nB2_VFIMFF5 / @nSaldo01
           End
        End
        update SB2###
           set B2_VFIMFF1 = @nB2_VFIMFF1, B2_CMFF1 = @nB2_CMFF1, B2_VFIMFF2 = @nB2_VFIMFF2, B2_CMFF2 = @nB2_CMFF2,
               B2_VFIMFF3 = @nB2_VFIMFF3, B2_CMFF3 = @nB2_CMFF3, B2_VFIMFF4 = @nB2_VFIMFF4, B2_CMFF4 = @nB2_CMFF4,
               B2_VFIMFF5 = @nB2_VFIMFF5, B2_CMFF5 = @nB2_CMFF5, B2_QFIMFF  = @nB2_QFIMFF
         where R_E_C_N_O_ = @nRecno
      End
      ##ENDFIELDP12

      /* --------------------------------------------------------------------------------------------------------------
         Tratamento para o DB2
      -------------------------------------------------------------------------------------------------------------- */
      SELECT @fim_CUR = 0
      fetch CUR_A330INI into @cFil_SB2  , @cCod      , @cLocal  , @nRecno  , @nB2_QFIM , @nB2_VFIM1 , @nB2_VFIM2 , @nB2_VFIM3 , @nB2_VFIM4 ,
                             @nB2_VFIM5 , @nB2_QFIM2 , @nB2_CM1 , @nB2_CM2 , @nB2_CM3  , @nB2_CM4   , @nB2_CM5   , @cB1_CCCUSTO
      /* --------------------------------------------------------------------------------------------------------------
         Tratamento especifico na procedure MAT007 para os bancos ORACLE/DB2.
         Ajuste necessario devido a falha do CURSOR apos o termino do mesmo, ou seja,
         apos o termino a variavel do cursor mantem o seu conteudo.
      -------------------------------------------------------------------------------------------------------------- */
      ##IF_002({|| Trim(TcGetDb()) == "ORACLE" .Or. Trim(TcGetDb()) = "DB2"})
      if @@fetch_status = -1 select @cCod = ' '
      ##ENDIF_002

      /* -------------------------------------------------------------------------------------------------------------
         Grava custo medio unificado para o produto
      ---------------------------------------------------------------------------------------------------------------*/
      if @IN_CUSUNIF in ('1','2') begin
         EXEC MAT043_## @cFILIALCOR, @cCodOriMod, @IN_MV_NEGESTR, @OutResult output
         if ( @OutResult = '1' ) begin
            select @nCM1aux = TRB_CM1, @nCM2aux = TRB_CM2, @nCM3aux = TRB_CM3, @nCM4aux = TRB_CM4, @nCM5aux = TRB_CM5
            from TRT### (nolock)
            where TRB_FILIAL = @cCusFilAux
               and TRB_COD = @cCodOriMod
            exec M330CMU_## @cFILIALCOR  , @cCodOriMod     , @IN_DDATABASE   ,
                        @nCM1aux         , @nCM2aux        , @nCM3aux        , @nCM4aux        , @nCM5aux        ,
                        @nTRB_CM1 output , @nTRB_CM2 output, @nTRB_CM3 output, @nTRB_CM4 output, @nTRB_CM5 output, @cExecutou output
            if ( @cExecutou = '1' ) begin
               Update TRT###
                  set TRB_CM1 = isnull(@nTRB_CM1, 0)
               where R_E_C_N_O_ = @iRecnoTRT
               select @iPos = Charindex( '2', @IN_MV_MOEDACM )
               If @iPos > 0 begin
                  Update TRT###
                     set TRB_CM2 = isnull(@nTRB_CM2, 0)
                  where R_E_C_N_O_ = @iRecnoTRT
               End
               select @iPos = Charindex( '3', @IN_MV_MOEDACM )
               If @iPos > 0 begin
                  Update TRT###
                     set TRB_CM3 = isnull(@nTRB_CM3, 0)
                  where R_E_C_N_O_ = @iRecnoTRT
               End
               select @iPos = Charindex( '4', @IN_MV_MOEDACM )
               If @iPos > 0 begin
                  Update TRT###
                     set TRB_CM4 = isnull(@nTRB_CM4, 0)
                  where R_E_C_N_O_ = @iRecnoTRT
               End
               select @iPos = Charindex( '5', @IN_MV_MOEDACM )
               If @iPos > 0 begin
                  Update TRT###
                     set TRB_CM5 = isnull(@nTRB_CM5, 0)
                  where R_E_C_N_O_ = @iRecnoTRT
               End
            End
         End
      End
   End -- Loop cursor SB2
   close      CUR_A330INI
   deallocate CUR_A330INI

/* -------------------------------------------------------------------------
    Atualiza saldos iniciais na SC2 - Ordens de Producao
   ------------------------------------------------------------------------- */
   begin transaction
   update SC2###
      set C2_VFIM1 = C2_VINI1, C2_APRFIM1 = C2_APRINI1
          ##FIELDP13( 'SC2.C2_VFIMRP1;SC2.C2_APRFRP1;SC2.C2_APRINI1;SC2.C2_APRIRP1' )
          , C2_VFIMRP1= C2_APRINI1, C2_APRFRP1 = C2_APRIRP1
          ##ENDFIELDP13
    where C2_FILIAL = @cFil_SC2
      and D_E_L_E_T_  = ' '
	  and (C2_DATRF = ' ' OR C2_DATRF >= @dDTINICIO )
   select @iPos = Charindex( '2', @IN_MV_MOEDACM )
   If @iPos > 0 begin
      update SC2###
         set C2_VFIM2 = C2_VINI2, C2_APRFIM2 = C2_APRINI2
         ##FIELDP14( 'SC2.C2_VFIMRP2;SC2.C2_APRFRP2;SC2.C2_APRINI2;SC2.C2_APRIRP2' )
         , C2_VFIMRP2= C2_APRINI2, C2_APRFRP2 = C2_APRIRP2
         ##ENDFIELDP14
       where C2_FILIAL = @cFil_SC2
         and D_E_L_E_T_ = ' '
		 and (C2_DATRF = ' ' OR C2_DATRF >= @dDTINICIO )
   End
   select @iPos = Charindex( '3', @IN_MV_MOEDACM )
   If @iPos > 0 begin
      update SC2###
         set C2_VFIM3 = C2_VINI3, C2_APRFIM3 = C2_APRINI3
          ##FIELDP15( 'SC2.C2_VFIMRP3;SC2.C2_APRFRP3;SC2.C2_APRINI3;SC2.C2_APRIRP3' )
          ,C2_VFIMRP3= C2_APRINI3, C2_APRFRP3 = C2_APRIRP3
          ##ENDFIELDP15
       where C2_FILIAL = @cFil_SC2
         and D_E_L_E_T_ = ' '
		 and (C2_DATRF = ' ' OR C2_DATRF >= @dDTINICIO )
   End
   select @iPos = Charindex( '4', @IN_MV_MOEDACM )
   If @iPos > 0 begin
      update SC2###
         set C2_VFIM4 = C2_VINI4, C2_APRFIM4 = C2_APRINI4
          ##FIELDP16( 'SC2.C2_VFIMRP4;SC2.C2_APRFRP4;SC2.C2_APRINI4;SC2.C2_APRIRP4' )
          , C2_VFIMRP4= C2_APRINI4, C2_APRFRP4 = C2_APRIRP4
          ##ENDFIELDP16
      where C2_FILIAL = @cFil_SC2
         and D_E_L_E_T_ = ' '
         and (C2_DATRF = ' ' OR C2_DATRF >= @dDTINICIO )
   End
   select @iPos = Charindex( '5', @IN_MV_MOEDACM )
   If @iPos > 0 begin
      update SC2###
         set C2_VFIM5 = C2_VINI5, C2_APRFIM5 = C2_APRINI5
          ##FIELDP17( 'SC2.C2_VFIMRP5;SC2.C2_APRFRP5;SC2.C2_APRINI5;SC2.C2_APRIRP5' )
          , C2_VFIMRP5= C2_APRINI5, C2_APRFRP5 = C2_APRIRP5
          ##ENDFIELDP17
       where C2_FILIAL = @cFil_SC2
         and D_E_L_E_T_ = ' '
		 and (C2_DATRF = ' ' OR C2_DATRF >= @dDTINICIO )
   End

   /* Atualiza campos de custo FIFO / LIFO  */
   If @IN_MV_CUSFIFO = '1' begin
      update SC2###
      set C2_VFIMFF1 = C2_VINIFF1, C2_APFIFF1 = C2_APINFF1
      where C2_FILIAL = @cFil_SC2
      and D_E_L_E_T_  = ' '
      and (C2_DATRF = ' ' OR C2_DATRF >= @dDTINICIO )
      select @iPos = Charindex( '2', @IN_MV_MOEDACM )
      If @iPos > 0 begin
         update SC2###
         set C2_VFIMFF2 = C2_VINIFF2, C2_APFIFF2 = C2_APINFF2
         where C2_FILIAL = @cFil_SC2
         and D_E_L_E_T_  = ' '
		 and (C2_DATRF = ' ' OR C2_DATRF >= @dDTINICIO )
      End
      select @iPos = Charindex( '3', @IN_MV_MOEDACM )
      If @iPos > 0 begin
         update SC2###
	     set C2_VFIMFF3 = C2_VINIFF3, C2_APFIFF3 = C2_APINFF3
         where C2_FILIAL = @cFil_SC2
         and D_E_L_E_T_ = ' '
		 and (C2_DATRF = ' ' OR C2_DATRF >= @dDTINICIO )
      End
      select @iPos = Charindex( '4', @IN_MV_MOEDACM )
      If @iPos > 0 begin
         update SC2###
	     set C2_VFIMFF4 = C2_VINIFF4, C2_APFIFF4 = C2_APINFF4
         where C2_FILIAL = @cFil_SC2
         and D_E_L_E_T_  = ' '
		 and (C2_DATRF = ' ' OR C2_DATRF >= @dDTINICIO )
      End
      select @iPos = Charindex( '5', @IN_MV_MOEDACM )
      If @iPos > 0 begin
         update SC2###
	     set C2_VFIMFF5 = C2_VINIFF5, C2_APFIFF5 = C2_APINFF5
         where C2_FILIAL = @cFil_SC2
         and D_E_L_E_T_ = ' '
	     and (C2_DATRF = ' ' OR C2_DATRF >= @dDTINICIO )
      End
   End
   commit transaction
/* ------------------------------------------------------------------------------------------------------------------
      Gravar os Valores finais no SC2 com o CUSTO EM PARTES.
   ------------------------------------------------------------------------------------------------------------------ */
   exec M330INC2CP_## @cFILIALCOR
/* ------------------------------------------------------------------------------------------------------------------
      Processa o saldo inicial FIFO / LIFO
   ------------------------------------------------------------------------------------------------------------------ */
   exec MAT054_## @cFILIALCOR, @IN_CFILAUX, @dDTINICIO, @IN_MV_MOEDACM, @cMV_PAR1, @IN_MV_CUSFIFO, @OutResult output
   if ( @OutResult = '1' ) begin
/*       -------------------------------------------------------------------------
         Final do processo retornando '1' como processo  encerrado por completo
         ------------------------------------------------------------------------- */
      select @OUT_RESULTADO = '1'
   end
end
