CREATE PROCEDURE MAT004_##
(
   @IN_FILIALCOR   char('B2_FILIAL'),
   @IN_MV_NIVALT   char(01),
   @IN_MV_LOCPROC  char('B2_LOCAL'),
   @IN_MV_PAR1     char(08),
   @IN_MV_PAR09    integer,
   @IN_MV_PAR11    integer,
   @IN_MV_PAR14    integer,
   @IN_MV_CUSFIFO  char(01),
   @IN_MV_RASTRO   char(01),
   @IN_MV_LOCALIZ  char(01),
   @IN_MV_CQ       char('B2_LOCAL'),
   @IN_DINICIO     char(08),
   @IN_TAM_TRB_DOC integer,
   @IN_COPCOES     char(04),
   @IN_CUSUNIF     char(01),
   @IN_MV_PRODPR0  integer,
   @IN_DDATABASE   char(08),
   @IN_MV_NEGESTR  char(01),
   @IN_RECNOSMO    integer,
   @IN_MV_PAR18    integer,
   @IN_CPAISLOC    Char( 03 ),
   @IN_FILSEQ      integer,
   @IN_MV_PRODMNT  Char('B1_COD'),
   @IN_MV_MOEDACM  Char(5),
   @IN_MV_D3SERVI  Char(01),
   @IN_INTDL       Char(01),
   @IN_MV_CUSREP   Char(01),
   @IN_MV_PAR15    integer,
   @IN_USAFILTRF   Char(01),
   @IN_SEQ500      Char(01),
   @IN_MVULMES     Char(08),
   @IN_MV_WMSNEW   Char(01),
   @IN_MV_PRODMOD   Char(01),
   @IN_MV_SEQREBE   Char(03),
   @IN_MV_330JCM1  Char(05),
   @IN_MV_PROCQE6  Char(01),
   @IN_FILIALPROC  Char('B2_FILIAL'),
   @OUT_RESULTADO  char(01) OutPut
)
as
/* ------------------------------------------------------------------------------
    Programa    -  <s> A330GRVTRB() </s>
    Versão      -  <v> Protheus P12 </v>
    Descricao   -  <d> Recalculo do custo medio - Gravacao de arquivo de trabalho por nivel da estrutura </d>
    Assinatura  -  <a> 007 </a>
    Entrada     -  <ri>
                   @IN_FILIALCOR    - Filial Corrente
                   @IN_MV_NIVALT    - Define se a estrutura teve ou nao alteracoes.
                   @IN_MV_LOCPROC   - Local padrao a ser enviado os materiais  indiretos em processo.
                   @IN_MV_PAR1      - Data limite para processamento
                   @IN_MV_PAR11     - Gera estrutura p/movimentos
                   @IN_MV_PAR14     - Metodo Apropriacao 1 = Sequencial 2 = Mensal    3 = Diaria
                   @IN_MV_CUSFIFO   - Informe se no calculo do custo medio tambem sera efetuado o calculo do custo FIFO. (S)im ou (N)ao.
                   @IN_MV_RASTRO    - Determina a utilizacao ou nao  da  Rastreabilidade dos Lotes de Producao (Informar S para  Sim  ou  N
                   @IN_MV_LOCALIZ   - Indica se produtos poderao usar controle de localizacao fisica ou nao. (S)im ou (N)ao.
                   @IN_MV_CQ        - Almoxarifado do controle de qualidade
                   @IN_DINICIO      - Data Inicial para processamento
                   @IN_TAM_TRB_DOC  - Tamanho do campo que contem os números de documentos
                   @IN_COPCOES      - Parametros de tipo logico, agrupados
                   @IN_CUSUNIF      - Indica se o custo é processado por armazem ou unificado.
                   @IN_DDATABASE    - Data base do sistema
                   @IN_MV_NEGESTR   - Permiti Incluir Itens negativos na estrutura
                   @IN_MV_D3SERVI   - Considera ou nao movimentos de WMS (SD3) sem execucao do servico (1-sim/0-nao)
                   @IN_INTDL        - Indica se existe integracao com WMS (1-sim/0-nao)
                   @IN_MV_CUSREP    - Indica se utiliza o custo de reposicao
                   @IN_MV_PAR15     -  integer,
                   @IN_USAFILTRF    - Indica se utiliza filial de transferencia
                   @IN_SEQ500       - Indice se utiliza o parametro MV_SE500
                   @IN_MVULMES      - Conteudo do parametro MV_ULMES
                   </ri>
    Responsavel :  <r> Marco Norbiato </r>
    Data        :  <dt> 30/03/2000 </dt>
    <o> Uso         :  MATA330 </o>

    Estrutura de chamadas
    ========= == ========

    0.MAT004 - Recalculo do custo medio - Gravacao de arquivo de trabalho por nivel da estrutura
      1.MAT005 - Atualiza a coluna G1_NIV e G1_NIVINV
      1.MAT007 - Pega valores do inicio do periodo para serem reprocessados
        2.MAT006 - Retorna o Saldo do Produto/Local do arquivo SB9 - Saldos Iniciais
        2.MAT043 - Verifica se pode alterar o custo medio do produto
        2.M330CMU - Pega valores de custo do produto quando o mesmo é sucata ( resíduo )
          3.MAT020  -  Recupera taxa para moeda na data em questao
        2.M330INB2CP - Gravar os Valores finais no SB2 com o CUSTO EM PARTES.
        2.M330INC2CP - Atualiza partes do custo em partes no SC2
      1.MAT042 - Verifica se a remessa ocorreu em outro periodo
      1.MAT009 - Grava arquivo de trabalho por nivel da estrutura
        2.MA330SEQ - Ponto de entrada para mudar a sequencia do calculo
      1.MAT013 - Apaga movimentos de estorno no SD
        2.MAT011 - Pesquisa no SB1 se produto corrente usa rastreabilidade
        2.MAT012 - Pesquisa no SB1 se produto corrente usa localizacao fisica
      1.MAT015 - Grava os niveis TRB_NIVEL / TRB_NIVSD3 referentes ao SC2 ou SG1 no TRB
        2.MAT005 - Atualiza a coluna G1_NIV e G1_NIVINV
        2.MAT014 - Verifica se o produto da transferencia tem estrutura

------------------------------------------------------------------------------------------------------------------------

Sequencias de Calculo
---------------------
 080 -> Movimento de Ajuste Cambial (Localizacao Bolivia)              - Arquivo SD3
 095 -> LOCALIZACOES - Remitos de entrada por compra                   - Arquivo SCM
 100 -> Compras                                                        - Arquivo SD1
 110 -> Movimentacoes do CQ                                            - Arquivo SD3
 120 -> Entrada de beneficiamento efetuado fora e Req. para OP (RE5)   - PERIODO ANTERIOR - Arquivos SD1 e SD3
 145 -> LOCALIZACOES - Devolucao Compras                               - Arquivo SCM
 150 -> Devolucao Compras                                              - Arquivo SD2
 195 -> LOCALIZACOES - Devolucao de Vendas Mes Anterior                - Arquivo SCN
 200 -> Devolucao Vendas Periodo Anterior                              - Arquivo SD1
 250 -> Remessa Beneficiamento "Eu Benef."                             - Arquivo SD1
 280 -> Retorno Beneficiamento "Fora"                                  - PERIODO ANTERIOR - Arquivo SD1
 290 -> Retorno Beneficiamento "Eu Benef."                             - Arquivo SD2 [MV_SEQREBE = '290'
 300 -> Movimentacoes Internas (menos req. p/ consumo e transferencia) - Arquivo SD3
 300 -> Movimentacoes Internas de transferencia                  w     - Arquivo SD3
 300 -> Saida para transferencia entre filiais                   w     - Arquivo SD2
 300 -> Entrada de transferencia entre filiais                   w     - Arquivo SD1
 300 -> Remessa Beneficiamento "Fora" de Produtos sem estrutura  x     - Arquivo SD2
 300 -> Retorno Beneficiamento "Fora" de Produtos sem estrutura  y     - Arquivo SD1
 300 -> Remessa Beneficiamento "Fora" de Produtos com estrutura  x     - Arquivo SD1
 300 -> Retorno Beneficiamento "Fora" de Produtos com estrutura  y     - Arquivo SD2
 300 -> Entrada de beneficiamento efetuado fora e Req. para OP (RE5)   - Arquivo SD1 e SD3
 301 -> Requisicoes para Consumo									   - Arquivo SD3
 302 -> Retorno Beneficiamento "Eu Benef."                             - Arquivo SD2 [MV_SEQREBE = '302']
 480 -> Apontamento de Projetos ( SIGAPMS )
 495 -> LOCALIZACOES - Remitos de saida Vendas "SCN"
 500 -> Vendas "SD2"												   - Arquivo SD2
 500 -> Devolucoes Vendas do periodo                                   - Arquivo SD1
 545 -> LOCALIZACOES - Devolucao de Vendas do Mes "SCN"
 600 -> Reavaliacao de Custo (REA/DEA)                                 - Arquivo SD3

--------------------------------------------------------------------------------------------------------------------- */
declare @cFil_AFN    char('AFN_FILIAL')
declare @cFil_SD1    char('D1_FILIAL')
declare @cFil_SD2    char('D2_FILIAL')
declare @cFil_SD3    char('D3_FILIAL')
declare @cFil_SF4    char('F4_FILIAL')
declare @cFil_SG1    char('G1_FILIAL')
declare @cFil_SB1    char('B1_FILIAL')

declare @cExecutou   char(01)
declare @vContador   integer

declare @vRecnoD1    integer
declare @vRecnoMNT   integer
declare @cF4_PODER3  char('F4_PODER3')
declare @cF4_ESTOQUE char('F4_ESTOQUE')
declare @cD1_COD     char('D1_COD')
declare @cD1_TIPO    char('D1_TIPO')
declare @cD1_OP      char('D1_OP')
declare @cD1_NUMSEQ  char('D1_NUMSEQ')
declare @cD1_LOCAL   char('D1_LOCAL')
declare @cD1_DOC     char('D1_DOC')
declare @cD1_SERIE   char('D1_SERIE')
declare @cD1_FORNECE char('D1_FORNECE')
declare @cD1_LOJA    char('D1_LOJA')
declare @cD1_ITEM    char('D1_ITEM')
declare @cD1_TIPODOC char('D1_TIPODOC')
declare @nD1_QUANT   Float

declare @vRecnoD2    integer
declare @cD2_COD     char('D2_COD')
declare @cD2_LOCAL   char('D2_LOCAL')
declare @cD2_TIPO    char('D2_TIPO')
declare @cD2_TIPODOC char('D2_TIPODOC')

declare @vRecnoD3    integer
declare @vRecnoD7    integer
declare @cD3_COD     char('D3_COD')
declare @cD3_LOCAL   char('D3_LOCAL')
declare @cD3_CF      char('D3_CF')
declare @cD3_NUMSEQ  char('D3_NUMSEQ')
declare @cD3_DOC     char('D3_DOC')
declare @cD3_ESTORNO char('D3_ESTORNO')
declare @cD3_LOTECTL char('D3_LOTECTL')
declare @cD3_NUMLOTE char('D3_NUMLOTE')
declare @cD3_PROJPMS char('D3_PROJPMS')
Declare @cD3_OP      char('D3_OP')
Declare @cD3_IDENT   char('D3_IDENT')
Declare @cD3_EMISSAO char('D3_EMISSAO')
Declare @cD3_CHAVE   char('D3_CHAVE')

declare @nRecTRB     integer
declare @iRecCount   integer
declare @MV_PAR14    integer
declare @cMDia       char(01) -- indica se o produto foi beneficiado e entregue no mesmo dia
declare @cAux        Varchar(3)
declare @cAux1       Varchar(3)
declare @nAux        integer
declare @nAptmPMS    integer
declare @nAptmPMSTMP integer
declare @iTRA_RECNO  integer
declare @cTransf     char(01)
declare @nRecnoSD3   integer
declare @cD3_STATUS  Varchar(2)

Declare @fim_CUR     integer //Tratamento para o DB2

declare @cMV_PAR1     char(08)
declare @cDINICIO     char(08)
declare @cMV_PRODMNT  Char('B1_COD')
declare @cFILIALCOR   char('B2_FILIAL')
declare @cMV_CQ       char('B2_LOCAL')
Declare @cB1_CCCUSTO  char('B1_CCCUSTO')
declare @nConSD3      char(01)

begin

   /* -------------------------------------------------------------------------
    Evitando Parameter Sniffing
   ------------------------------------------------------------------------- */
   select @cMV_PAR1 = @IN_MV_PAR1
   select @cDINICIO = @IN_DINICIO
   select @cMV_PRODMNT = @IN_MV_PRODMNT
   select @cFILIALCOR = @IN_FILIALCOR
   select @cMV_CQ = @IN_MV_CQ

   select @cAux = 'AFN'
   EXEC XFILIAL_## @cAux, @cFILIALCOR, @cFil_AFN OutPut
   select @cAux = 'SD1'
   EXEC XFILIAL_## @cAux, @cFILIALCOR, @cFil_SD1 OutPut
   select @cAux = 'SD2'
   EXEC XFILIAL_## @cAux, @cFILIALCOR, @cFil_SD2 OutPut
   select @cAux = 'SD3'
   EXEC XFILIAL_## @cAux, @cFILIALCOR, @cFil_SD3 OutPut
   select @cAux = 'SF4'
   EXEC XFILIAL_## @cAux, @cFILIALCOR, @cFil_SF4 OutPut
   select @cAux = 'SG1'
   EXEC XFILIAL_## @cAux, @cFILIALCOR, @cFil_SG1 OutPut
   select @cAux = 'SB1'
   EXEC XFILIAL_## @cAux, @cFILIALCOR, @cFil_SB1 OutPut

   select @OUT_RESULTADO = '0'
   select @cExecutou     = ' '
   select @vRecnoD3      = 0
   select @vRecnoD7      = 0
   select @cD3_ESTORNO   = ' '
   select @MV_PAR14      = @IN_MV_PAR14
   select @cTransf       = '0'
   select @nAptmPMS      = 0
   select @nAptmPMSTMP   = 0
   select @cD3_STATUS    = '  '
   select @vRecnoD1      = 0
   select @cB1_CCCUSTO = ' '
   select @nConSD3       = '0'

   /*---------------------------------------------------------------
      Pega valores do inicio do periodo para serem reprocessados
   ----------------------------------------------------------------*/
   select @cAux = '  '

   EXEC MAT007_## @cFILIALCOR, @cAux, @cDINICIO, @IN_MV_LOCPROC, @IN_COPCOES, @IN_CUSUNIF, @IN_DDATABASE, @IN_MV_NEGESTR, @IN_MV_MOEDACM, @IN_MV_PAR1, @IN_MV_CUSFIFO,@cMV_PRODMNT,@IN_MV_D3SERVI,@IN_INTDL,@cMV_CQ,@IN_MVULMES,@IN_MV_WMSNEW,@IN_MV_PRODMOD, @cExecutou OUTPUT

   /*---------------------------------------------------------------
      Processando as compras
   ----------------------------------------------------------------*/
   declare SD1_Cursor insensitive cursor for
      select SD1.R_E_C_N_O_, SF4.F4_PODER3, D1_COD, D1_TIPO, D1_OP, D1_NUMSEQ, D1_DOC, D1_SERIE, D1_FORNECE,
             D1_LOJA,        D1_ITEM,       D1_TIPODOC,      D1_LOCAL, SF4.F4_ESTOQUE, D1_QUANT
      from SD1### SD1, SF4### SF4
      where SD1.D1_FILIAL   = @cFil_SD1
         and SF4.F4_FILIAL   = @cFil_SF4
         and SD1.D1_DTDIGIT >= @cDINICIO
         and SD1.D1_DTDIGIT <= @cMV_PAR1
         and SD1.D1_TES      = SF4.F4_CODIGO
         and SF4.F4_ESTOQUE  = 'S'
         and SD1.D1_ORIGLAN <> 'LF'
         and SD1.D1_REMITO   = ' '
         and SD1.D_E_L_E_T_  = ' '
         and SF4.D_E_L_E_T_  = ' '
   for read only
   open SD1_Cursor
   fetch SD1_Cursor into @vRecnoD1,  @cF4_PODER3, @cD1_COD,     @cD1_TIPO, @cD1_OP,   @cD1_NUMSEQ,
                         @cD1_DOC,   @cD1_SERIE,  @cD1_FORNECE, @cD1_LOJA, @cD1_ITEM, @cD1_TIPODOC,
                         @cD1_LOCAL, @cF4_ESTOQUE, @nD1_QUANT
   while @@Fetch_Status = 0 begin

      select @nRecnoSD3 = 0
      select @cB1_CCCUSTO = ' '

      If ( @cD1_OP <> ' ' ) AND ( @cF4_ESTOQUE = 'S' ) AND ( @cF4_PODER3 NOT IN ( 'R','S' ) ) begin
         select @nRecnoSD3 = isnull(R_E_C_N_O_,0)
         from SD3### SD3
         where SD3.D3_FILIAL  = @cFil_SD3
            and ( ( ( @cMV_CQ = @cD1_LOCAL ) and ( SD3.D3_IDENT = @cD1_NUMSEQ ) ) or
                  ( ( @cMV_CQ <> @cD1_LOCAL ) and ( SD3.D3_NUMSEQ  =  @cD1_NUMSEQ  ) ) )
            and SD3.D3_EMISSAO  >= @cDINICIO
            and SD3.D3_EMISSAO  <= @cMV_PAR1
            and SD3.D3_CF      = 'RE5'
            and SD3.D3_COD     = @cD1_COD
            and SD3.D3_OP      = @cD1_OP
			and SD3.D3_QUANT   = @nD1_QUANT
            and SD3.D3_ESTORNO = ' '
            and SD3.D_E_L_E_T_ = ' '
      End
      if @nRecnoSD3 is Null select @nRecnoSD3 = 0
      if ( @cD1_TIPO <> 'D' ) begin -- verifica se é uma devolução
         if ( @cF4_PODER3 = 'D' ) begin -- verifica se é uma devolução que está em poder de terceiros
            /*------------------------------------------------------------
               Grava Retorno Beneficiamento ( FORA ).
            -----------------------------------------------------------*/
            select @cAux = 'D'
            EXEC MAT042_## @cFILIALCOR, @cAux, @cMV_PAR1, @IN_MV_PAR14, @vRecnoD1, @cDINICIO, @cMDia output
            if (@cMDia = '1') begin
               select @cAux  = 'SD1'
               select @cAux1 = '300'
               select @nAux  = 0
               EXEC MAT009_## @cAux, @cAux1, @vRecnoD1, @nRecnoSD3, @nAux, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
            end else begin
               select @cAux  = 'SD1'
               select @cAux1 = '280'
               select @nAux  = 0
               EXEC MAT009_## @cAux, @cAux1, @vRecnoD1, @nRecnoSD3, @nAux, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
            end
         end else begin
            if ( @cF4_PODER3 = 'R' ) begin
               select @cAux  = 'SD1'
               select @cAux1 = '250'
               select @nAux  = 0
               EXEC MAT009_## @cAux, @cAux1, @vRecnoD1, @nRecnoSD3, @nAux, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
            end else begin
               if @nRecnoSD3 = 0 begin
                  select @cAux  = 'SD1'
                  select @nAux  = 0
                  if ( @cD1_TIPODOC >= '50' ) begin
                     select @cAux1 = '095'
                     select @nAux  = 0
                     EXEC MAT009_## @cAux, @cAux1, @vRecnoD1, @nRecnoSD3, @nAux, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
                  end else begin
                     select @cAux1 = '100'
                     select @nAux  = 0
                     EXEC MAT009_## @cAux, @cAux1, @vRecnoD1, @nRecnoSD3, @nAux, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
                  end
               end
            end
         end
      end else begin
         if ( @cD1_TIPO = 'D' ) begin
            select @cAux = 'V'
            Exec MAT042_## @cFILIALCOR, @cAux, @cMV_PAR1, @IN_MV_PAR14, @vRecnoD1, @cDINICIO, @cMDia output
            select @cAux  = 'SD1'
            select @nAux  = 0
            if ( @cMDia = '1' ) begin
               if ( @cD1_TIPODOC >= '50' ) begin
                  select @cAux1 = '545'
                  EXEC MAT009_## @cAux, @cAux1, @vRecnoD1, @nRecnoSD3, @nAux, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
               end else begin
                  select @cAux1 = '500'
                  EXEC MAT009_## @cAux, @cAux1, @vRecnoD1, @nRecnoSD3, @nAux, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
               end
            end else begin
                if ( @cD1_TIPODOC >= '50' ) begin
                   select @cAux1 = '195'
                   EXEC MAT009_## @cAux, @cAux1, @vRecnoD1, @nRecnoSD3, @nAux, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
                end else begin
                   select @cAux1 = '200'
                   EXEC MAT009_## @cAux, @cAux1, @vRecnoD1, @nRecnoSD3, @nAux, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
                end
            end
         end
      end
      if ( ( @cD1_OP <> ' ' ) or ( @nAptmPMS > 0 ) ) and ( @cF4_PODER3 not in ( 'R','S' ) ) begin
         select @nAptmPMS = isnull( count(*), 0 )
         from AFN### AFN ( nolock )
         where AFN_FILIAL = @cFil_AFN
            and AFN_DOC    = @cD1_DOC
            and AFN_SERIE  = @cD1_SERIE
            and AFN_FORNEC = @cD1_FORNECE
            and AFN_LOJA   = @cD1_LOJA
            and AFN_ITEM   = @cD1_ITEM
            and AFN_ESTOQU <> '2'
            and D_E_L_E_T_ = ' '
         select @nRecTRB = MAX( R_E_C_N_O_ ) from TRB### (nolock) where TRB_FILIAL = @cFILIALCOR
         if @nRecTRB is Null select @nRecTRB = 0
         select @nConSD3 = '0'
         declare SD3_Cursor01 insensitive cursor for
            select SD3.R_E_C_N_O_, D3_COD, D3_NUMSEQ, D3_LOCAL, D3_LOTECTL, D3_NUMLOTE, D3_DOC, D3_ESTORNO, IsNull(SB1.B1_CCCUSTO,' ')
            from SD3### SD3
            left join SB1### SB1 on SB1.B1_FILIAL = @cFil_SB1 and SB1.B1_COD = SD3.D3_COD and SB1.D_E_L_E_T_  = ' '
            where SD3.D3_FILIAL  = @cFil_SD3
               and ( ( ( SD3.D3_IDENT = @cD1_NUMSEQ ) ) or
                     ( ( @cMV_CQ <> @cD1_LOCAL ) and ( SD3.D3_NUMSEQ  =  @cD1_NUMSEQ  ) ) )
               and SD3.D3_EMISSAO  >= @cDINICIO
               and SD3.D3_EMISSAO  <= @cMV_PAR1
               and SD3.D3_CF      = 'RE5'
               and SD3.D3_COD     = @cD1_COD
               and SD3.D3_OP      = @cD1_OP
               and SD3.D3_ESTORNO = ' '
               and SD3.D_E_L_E_T_ = ' '
         for read only
         open  SD3_Cursor01
         fetch SD3_Cursor01 into @vRecnoD3, @cD3_COD, @cD3_NUMSEQ, @cD3_LOCAL, @cD3_LOTECTL, @cD3_NUMLOTE, @cD3_DOC, @cD3_ESTORNO, @cB1_CCCUSTO
         while @@Fetch_Status = 0 begin
            if ( @vRecnoD3 is null ) select @vRecnoD3 = 0
            if ( @nConSD3 = '0' ) begin
               if @cMV_CQ = @cD1_LOCAL begin
                  select @nConSD3 = '1'
               end
               if ( @cD1_TIPO <> 'D' ) begin
                  if ( @cF4_PODER3 = 'D' ) begin
                     select @cAux = 'D'
                     EXEC MAT042_## @cFILIALCOR, @cAux, @cMV_PAR1, @IN_MV_PAR14, @vRecnoD1, @cDINICIO, @cMDia output
                     if (@cMDia = '1') begin
                        /*----------------------------------------------------------
                        Grava Retorno Beneficiamento ( FORA ).
                        ------------------------------------------------------------*/
                        select @cAux  = 'SD3'
                        select @cAux1 = '300'
                        EXEC MAT009_## @cAux, @cAux1, @vRecnoD3, @vRecnoD1, @nRecTRB, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
                     end else begin
                        /*----------------------------------------------------------
                        Grava Movimentacoes Internas.
                        ------------------------------------------------------------*/
                        select @cAux  = 'SD3'
                        select @cAux1 = '280'
                        EXEC MAT009_## @cAux, @cAux1, @vRecnoD3, @vRecnoD1, @nRecTRB, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
                     end

                     Begin tran
                        update TRB###
                        set TRB_RECSD1 = @vRecnoD3
                        where R_E_C_N_O_ = @nRecTRB
                     Commit Tran

                  end else if ( @cF4_PODER3 <> 'R' ) begin
                     if ( @nAptmPMS > 0 ) begin
                        select @vContador = @nAptmPMS
                        while ( @vContador > 0 ) begin
                           select @cAux1   = '300'
                           select @cAux    = 'SD1'
                           select @nRecTRB = 0
                           EXEC MAT009_## @cAux, @cAux1, @vRecnoD1, @vRecnoD3, @nRecTRB, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, ' ',@IN_FILIALPROC
                           select @nRecTRB = max( R_E_C_N_O_ ) from TRB### where TRB_FILIAL = @cFILIALCOR
                           if @nRecTRB is Null select @nRecTRB = 0
                           select @cAux1   = '300'
                           select @cAux    = 'SD3'
                           EXEC MAT009_## @cAux, @cAux1, @vRecnoD3, @vRecnoD1, @nRecTRB, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
                           select @vContador = @vContador - 1
                        end
                     end else begin
                        select @cAux1   = '300'
                        select @cAux    = 'SD1'
                        select @nAux    = 0
                        select @nRecTRB = 0
                        EXEC MAT009_## @cAux, @cAux1, @vRecnoD1, @nAux, @nRecTRB, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, ' ',@IN_FILIALPROC
                        select @nRecTRB = max( R_E_C_N_O_ ) from TRB### where TRB_FILIAL = @cFILIALCOR
                        if @nRecTRB is Null select @nRecTRB = 0
                        select @cAux    = 'SD3'
                        select @cAux1   = '300'
                        EXEC MAT009_## @cAux, @cAux1, @vRecnoD3, @vRecnoD1, @nRecTRB, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
                     end
                  end
               end
            end
            /* --------------------------------------------------------------------------------------------------------------
               Tratamento para o DB2
            -------------------------------------------------------------------------------------------------------------- */
            select @fim_CUR = 0

            fetch SD3_Cursor01 into @vRecnoD3, @cD3_COD, @cD3_NUMSEQ, @cD3_LOCAL, @cD3_LOTECTL, @cD3_NUMLOTE, @cD3_DOC, @cD3_ESTORNO, @cB1_CCCUSTO
         end
         close      SD3_Cursor01
         deallocate SD3_Cursor01
      end

      /* --------------------------------------------------------------------------------------------------------------
         Tratamento para o DB2
      -------------------------------------------------------------------------------------------------------------- */
      select @fim_CUR = 0

      fetch SD1_Cursor into @vRecnoD1,  @cF4_PODER3, @cD1_COD,     @cD1_TIPO, @cD1_OP,   @cD1_NUMSEQ,
                            @cD1_DOC,   @cD1_SERIE,  @cD1_FORNECE, @cD1_LOJA, @cD1_ITEM, @cD1_TIPODOC,
                            @cD1_LOCAL, @cF4_ESTOQUE,@nD1_QUANT

   end
   close      SD1_Cursor
   deallocate SD1_Cursor
   /* -----------------------------
      Final do Processamento do SD1
   -------------------------------- */

   /* ----------------------------------------------
      Processa as Vendas, Devolucoes, Beneficiamento
   ------------------------------------------------- */
   select @nAptmPMSTMP = 0
   select @cAux = 'SD2'
   declare SD2_Cursor insensitive cursor for
      select SD2.R_E_C_N_O_, D2_COD, D2_LOCAL, D2_TIPO, F4_PODER3, D2_TIPODOC
      from SD2### SD2, SF4### SF4
      where SD2.D2_FILIAL   = @cFil_SD2
         and SF4.F4_FILIAL   = @cFil_SF4
         and SD2.D2_EMISSAO >= @cDINICIO
         and SD2.D2_EMISSAO <= @cMV_PAR1
         and SD2.D2_TES      = SF4.F4_CODIGO
         and SD2.D2_ORIGLAN <> 'LF'
         and (SD2.D2_REMITO   = ' ' or SD2.D2_REMITO <> ' ' and SD2.D2_TPDCENV in ('1', 'A'))
         and SF4.F4_ESTOQUE  = 'S'
         and SD2.D_E_L_E_T_  = ' '
         and SF4.D_E_L_E_T_  = ' '
   for read only
   open  SD2_Cursor
   fetch SD2_Cursor into @vRecnoD2, @cD2_COD, @cD2_LOCAL, @cD2_TIPO, @cF4_PODER3, @cD2_TIPODOC
   while (@@Fetch_Status = 0) begin

      select @cB1_CCCUSTO = ' '

      if ( @cD2_TIPO <> 'D' ) begin
         if (@cF4_PODER3 = 'R' ) begin
            /* -------------------------------------
               Grava Remessa Beneficiamento (FORA)
            ---------------------------------------- */
            select @cAux1 = '300'
            EXEC MAT009_## @cAux, @cAux1, @vRecnoD2, @nAptmPMSTMP, @nAptmPMSTMP, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
         end else if ( @cF4_PODER3 = 'D' ) begin
            /* ------------------------------------------
               Grava Retorno Beneficiamento (EU BENEF.)
            --------------------------------------------- */
            select @cAux1 = @IN_MV_SEQREBE
            EXEC MAT009_## @cAux, @cAux1, @vRecnoD2, @nAptmPMSTMP, @nAptmPMSTMP, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
         end else begin
            if ( @cD2_TIPODOC >= '50' ) begin
               /* ------------------------------------
                  Grava Notas Fiscais Venda (REMITO)
               --------------------------------------- */
               select @cAux1 = '495'
               EXEC MAT009_## @cAux, @cAux1, @vRecnoD2, @nAptmPMSTMP, @nAptmPMSTMP, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
            end else begin
               /* ----------------------------------------
                  Grava Notas Fiscais Venda (NOTA FISCAL)
               ------------------------------------------- */
               select @cAux1 = '500'
               EXEC MAT009_## @cAux, @cAux1, @vRecnoD2, @nAptmPMSTMP, @nAptmPMSTMP, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
            end
         end
      end else begin
         if ( @cD2_TIPODOC >= '50' ) begin
            /* ----------------------------------------------
               Grava Notas Fiscais de Dev. Compras (REMITO)
            ------------------------------------------------- */
            select @cAux1 = '145'
            EXEC MAT009_## @cAux, @cAux1, @vRecnoD2, @nAptmPMSTMP, @nAptmPMSTMP, @MV_PAR14,  @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
         end else begin
            select @cAux1 = '150'
            EXEC MAT009_## @cAux, @cAux1, @vRecnoD2, @nAptmPMSTMP, @nAptmPMSTMP, @MV_PAR14,  @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
         end
      end

      /* --------------------------------------------------------------------------------------------------------------
         Tratamento para o DB2
      -------------------------------------------------------------------------------------------------------------- */
      select @fim_CUR = 0

      fetch SD2_Cursor into @vRecnoD2, @cD2_COD, @cD2_LOCAL, @cD2_TIPO, @cF4_PODER3, @cD2_TIPODOC
   end
   close      SD2_Cursor
   deallocate SD2_Cursor
   /* -----------------------------
      Final do Processamento do SD2
   -------------------------------- */

   /* ------------------------------------------------------------------------------------------------------------------
      Processa as movimentacoes internas SD3
   ------------------------------------------------------------------------------------------------------------------ */
   select @cF4_PODER3 = ' '
   declare SD3_Cursor insensitive cursor for
      select isnull( SD3.R_E_C_N_O_, 0 ) R_E_C_N_O_, D3_COD, D3_LOCAL, D3_CF, D3_NUMSEQ,  D3_DOC, D3_ESTORNO, D3_LOTECTL, D3_NUMLOTE, D3_PROJPMS, D3_OP,D3_IDENT,
             D3_EMISSAO, D3_CHAVE, IsNull(SB1.B1_CCCUSTO,' ')
      from SD3### SD3
      left join SB1### SB1 on SB1.B1_FILIAL = @cFil_SB1 and SB1.B1_COD = SD3.D3_COD and SB1.D_E_L_E_T_  = ' '
      where SD3.D3_FILIAL    = @cFil_SD3
         and SD3.D3_EMISSAO  >= @cDINICIO
         and SD3.D3_EMISSAO  <= @cMV_PAR1
         and SD3.D3_ESTORNO  = ' '
         and SD3.D_E_L_E_T_  = ' '
      order by SD3.D3_EMISSAO, SD3.D3_NUMSEQ, SD3.D3_CHAVE, SD3.D3_COD, SD3.R_E_C_N_O_
   for read only
   open SD3_Cursor
   fetch SD3_Cursor into @vRecnoD3,    @cD3_COD,     @cD3_LOCAL,   @cD3_CF, @cD3_NUMSEQ, @cD3_DOC, @cD3_ESTORNO,
                         @cD3_LOTECTL, @cD3_NUMLOTE, @cD3_PROJPMS, @cD3_OP, @cD3_IDENT,  @cD3_EMISSAO, @cD3_CHAVE, @cB1_CCCUSTO
   while @@Fetch_Status = 0 begin
      ---------------------------------------------------------------
         --Apaga movimentos de estorno
      ---------------------------------------------------------------
      if ( @vRecnoD3 is null ) select @vRecnoD3 = 0

      ---------------------------------------------------------------
         --Filtra RE5. ja processada no SD1
      ---------------------------------------------------------------
      if (@cD3_CF in ('RE5', 'DE5' )) begin
         select @iRecCount = 0
         select @iRecCount = isnull(R_E_C_N_O_,0)
         from TRB###
         where TRB_RECNO  = @vRecnoD3
            AND TRB_ALIAS  = 'SD3'

         if @iRecCount is Null select @iRecCount = 0
         if @iRecCount = 0 begin
            ---------------------------------------------------------------
              --Grava Movimentacoes Internas
            ---------------------------------------------------------------
            -- Verifica se o IDENT nao esta vazio
            if @cD3_IDENT <> ' ' begin
               select @vRecnoD1 = 0
               select @vRecnoD1 = isnull(R_E_C_N_O_,0)
               from SD1###
               where D1_FILIAL   = @cFil_SD1
                  and D1_NUMSEQ   = @cD3_IDENT
                  and D_E_L_E_T_  = ' '
             end else begin
               select @vRecnoD1 = 0
             end

            if @vRecnoD1 = 0 begin
               select @cAux  = 'SD3'
               select @cAux1 = '300'
               select @nAux  = 0
               EXEC MAT009_## @cAux, @cAux1, @vRecnoD3, @nAux, @nAux, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
            end else begin
               select @cAux  = 'SD3'
               select @cAux1 = '300'
               EXEC MAT009_## @cAux, @cAux1, @vRecnoD3, @vRecnoD1, @nAux, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
            end
         end
      end else begin
         ---------------------------------------------------------------
          --Grava Movimentacoes Internas.
         ---------------------------------------------------------------
         if ( @cD3_CF in ( 'RE8', 'DE8' ) ) begin
            -------------------------------------------------
            --Integracao com SIGAEIC
            -------------------------------------------------
            select @cAux  = 'SD3'
            select @cAux1 = '100'
            select @nAux  = 0
            EXEC MAT009_## @cAux, @cAux1, @vRecnoD3, @nAux, @nAux, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
         end else if @cD3_PROJPMS <> ' ' begin
            select @cAux  = 'SD3'
            select @cAux1 = '480'
            select @nAux  = 0
            EXEC MAT009_## @cAux, @cAux1, @vRecnoD3, @nAux, @nAux, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
         end else if ( @cD3_CF = 'RE0' ) and ( @cD3_OP = ' ' ) begin
            -------------------------------------------------
            --Requisicoes p/ Consumo
            -------------------------------------------------
            select @cAux  = 'SD3'
            select @cAux1 = '301'
            select @nAux  = 0
            EXEC MAT009_## @cAux, @cAux1, @vRecnoD3, @nAux, @nAux, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
         end else if ( @cD3_CF = 'RE4' OR @cD3_CF = 'DE4' ) AND @cD3_ESTORNO = 'S' begin
            select @iTRA_RECNO = 0
            select @iTRA_RECNO = isnull( MAX ( R_E_C_N_O_ ),0 )
            from TRA###
            where TRA_FILIAL = @cFILIALCOR
               and TRA_NUMSEQ = @cD3_NUMSEQ
               and TRA_CF     = @cD3_CF
               and TRA_COD    = @cD3_COD
               and D_E_L_E_T_ = ' '

            if @iTRA_RECNO = 0 begin
               begin tran
                   insert into TRA### ( TRA_FILIAL    , TRA_NUMSEQ  , TRA_CF  , TRA_COD )
                        values ( @cFILIALCOR , @cD3_NUMSEQ , @cD3_CF ,  @cD3_COD )
               Commit Tran

               select @cTransf = '1'
            end else begin
               select @cTransf = '2'
            end
            select @cAux  = 'SD3'
            select @cAux1 = '300'
            select @nAux  = 0
            EXEC MAT009_## @cAux, @cAux1, @vRecnoD3, @nAux, @nAux, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
         end else if ( @cD3_CF = 'RE6' OR @cD3_CF = 'DE6' ) begin

            select @vRecnoD7 = isnull( MAX ( R_E_C_N_O_ ) , 0 )
            from SD7###
            where D7_FILIAL  = @cFILIALCOR
               and D7_PRODUTO = @cD3_COD
               and D7_NUMSEQ  = @cD3_NUMSEQ
               and D7_NUMERO  = @cD3_DOC
               and D7_ORIGLAN = 'CP'
               and D_E_L_E_T_ = ' '

            If @cD3_LOCAL = @cMV_CQ and @vRecnoD7 > 0 begin
               select @cAux  = 'SD3'
               select @cAux1 = '110'
               select @nAux  = 0
               EXEC MAT009_## @cAux, @cAux1, @vRecnoD3, @nAux, @nAux, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
            end else begin
               if @vRecnoD7 > 0 begin
                  select @cAux  = 'SD3'
                  select @cAux1 = '110'
                  select @nAux  = 0
                  EXEC MAT009_## @cAux, @cAux1, @vRecnoD3, @nAux, @nAux, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
               end else begin
                  If @IN_MV_CUSREP = '1' begin
                     ##FIELDP01( 'SD3.D3_STATUS' )
                     select @cD3_STATUS = IsNull(SD3.D3_STATUS,'  ')
                     from SD3### SD3 ( nolock )
                     where SD3.R_E_C_N_O_ = @vRecnoD3 and
                           SD3.D_E_L_E_T_ = ' '
                     ##ENDFIELDP01
                     If @cD3_STATUS = 'RP' begin
                        select @cAux  = 'SD3'
                        select @cAux1 = '610'
                        select @nAux  = 0
                        EXEC MAT009_## @cAux, @cAux1, @vRecnoD3, @nAux, @nAux, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
                     end else begin
                        select @cAux  = 'SD3'
                        select @cAux1 = '300'
                        select @nAux  = 0
                        EXEC MAT009_## @cAux, @cAux1, @vRecnoD3, @nAux, @nAux, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
                     end
                  end else begin
                     If @IN_CPAISLOC = 'BOL' begin
                        ##FIELDP02( 'SD3.D3_STATUS' )
                        select @cD3_STATUS = IsNull(SD3.D3_STATUS,'  ')
                        from SD3### SD3 ( nolock )
                        where SD3.R_E_C_N_O_ = @vRecnoD3 and
                               SD3.D_E_L_E_T_ = ' '
                        ##ENDFIELDP02
                        If @cD3_STATUS = 'AC' begin
                           select @cAux  = 'SD3'
                           select @cAux1 = '080'
                           select @nAux  = 0
                           EXEC MAT009_## @cAux, @cAux1, @vRecnoD3, @nAux, @nAux, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
                        end else begin
                           select @cAux  = 'SD3'
                           select @cAux1 = '300'
                           select @nAux  = 0
                           EXEC MAT009_## @cAux, @cAux1, @vRecnoD3, @nAux, @nAux, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
                        end
                     end else begin
                        select @cAux  = 'SD3'
                        select @cAux1 = '300'
                        select @nAux  = 0
                        EXEC MAT009_## @cAux, @cAux1, @vRecnoD3, @nAux, @nAux, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
                     end
                  end
               end
            end
         end else if ( @cD3_CF = 'REA' OR @cD3_CF = 'DEA' ) begin
            select @cAux  = 'SD3'
            select @cAux1 = '600'
            select @nAux  = 0
            EXEC MAT009_## @cAux, @cAux1, @vRecnoD3, @nAux, @nAux, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
         end else begin
            select @cAux  = 'SD3'
            select @cAux1 = '300'
            select @nAux  = 0
            EXEC MAT009_## @cAux, @cAux1, @vRecnoD3, @nAux, @nAux, @MV_PAR14, @cMV_PAR1, @IN_MV_PRODPR0, @cFILIALCOR, @IN_RECNOSMO, @cTransf, @IN_CPAISLOC, @IN_USAFILTRF, @IN_SEQ500,@IN_MV_PRODMOD,@cMV_CQ,@IN_MV_PAR11,@IN_MV_PAR18,@IN_MV_330JCM1,@IN_MV_PROCQE6, @cB1_CCCUSTO,@IN_FILIALPROC
         end
      end
      /* --------------------------------------------------------------------------------------------------------------
         Tratamento para o DB2
      -------------------------------------------------------------------------------------------------------------- */
      select @fim_CUR = 0

      fetch SD3_Cursor into @vRecnoD3,    @cD3_COD,     @cD3_LOCAL,   @cD3_CF, @cD3_NUMSEQ, @cD3_DOC, @cD3_ESTORNO,
                            @cD3_LOTECTL, @cD3_NUMLOTE, @cD3_PROJPMS, @cD3_OP, @cD3_IDENT,  @cD3_EMISSAO, @cD3_CHAVE, @cB1_CCCUSTO
   end
   close      SD3_Cursor
   deallocate SD3_Cursor

   /* -------------------------------------------------------------------------------------------------------
      Desconsiderar o produto MANUTENCAO(Conforme parametro MV_PRODMNT) do arquivo temporario
   ------------------------------------------------------------------------------------------------------- */
   if ( @cMV_PRODMNT <> ' ' ) begin
       select @vRecnoMNT = Isnull( Count(*), 0 )
      from SB1### (nolock)
      where B1_FILIAL = @cFil_SB1
          and B1_COD = @cMV_PRODMNT
          and D_E_L_E_T_ = ' '

       if @vRecnoMNT > 0 begin
          begin tran
            delete
            from TRB###
            where TRB_COD   = @cMV_PRODMNT
          commit tran
       end
    end

   /* -----------------------------
      Final do Processamento do SD3
   -------------------------------- */
   select @OUT_RESULTADO = '1'
end
