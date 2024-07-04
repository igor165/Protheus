Create procedure CTB023_##
( 
   @IN_FILIALCOR    Char('CT2_FILIAL'),
   @IN_FILIALATE    Char('CT2_FILIAL'),
   @IN_DATADE       Char(08),
   @IN_DATAATE      Char(08),
   @IN_LMOEDAESP    Char(01),
   @IN_MOEDA        Char('CT2_MOEDLC'),
   @IN_TPSALDO      Char('CT2_TPSALD'),
   @IN_MVSOMA       Char(01),
   @OUT_RESULTADO   Char(01) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA190.PRW </s>
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  Refaz saldos de documento  </d>
    Funcao do Siga  -      Ct190DOC() - Refaz saldos de documento não trata total informado
    Entrada         - <ri> @IN_FILIALCOR    - Filial Corrente
                           @IN_FILIALATE    - Filial final do processamento
                           @IN_DATADE       - Data Inicial
                           @IN_DATAATE      - Data Final
                           @IN_LMOEDAESP    - Moeda Especifica - '1', todas, exceto orca/o - '0'
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
                           @IN_MVSOMA       - Soma 2 vezes
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     31/03/2014
-------------------------------------------------------------------------------------- */
declare @cFilial_CT2  char('CT2_FILIAL')
declare @cCT2FilDe    char('CT2_FILIAL')
declare @cFilial_CTC  char('CTC_FILIAL')
declare @cFILCT2      char('CT2_FILIAL')
declare @cAux         char(03)
Declare @cCT2_DC      char('CT2_DC')
Declare @cCT2_DATA    Char(08)
Declare @cCT2_LOTE    Char('CT2_LOTE')
Declare @cCT2_SBLOTE  Char('CT2_SBLOTE')
Declare @cCT2_DOC     Char('CT2_DOC')
Declare @cCT2_MOEDLC  Char('CT2_MOEDLC')
Declare @nCT2_VALOR   Float
Declare @nCTC_DEBITO  Float
Declare @nCTC_CREDIT  Float
Declare @nCTC_DIG     Float
Declare @nCTC_DEBITOX Float
Declare @nCTC_CREDITX Float
Declare @nCTC_DIGX    Float
Declare @nCTC_INF     Float
Declare @iRecno       Integer
Declare @iTranCount   Integer --Var.de ajuste para SQLServer e Sybase.                             -- Será trocada por Commit no CFGX051 após passar pelo Parse
Declare @cFilCTCAnt   char('CT2_FILIAL')
Declare @cFirst       char(01)

begin
   
    select @OUT_RESULTADO = '0'
   
    If @IN_FILIALCOR = ' ' select @cCT2FilDe = ' '
    else select @cCT2FilDe = @IN_FILIALCOR
   
    select @cAux = 'CT2'
    exec XFILIAL_## @cAux, @cCT2FilDe, @cFilial_CT2 OutPut
   
    select @cFilCTCAnt = ' '
    select @cFilial_CTC = ' '
    select @cFirst = '0'
        
    Declare CUR_CT190DOC insensitive cursor for
        Select CT2_FILIAL, CT2_DC, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_MOEDLC, Sum(CT2_VALOR)
        From CT2###
        Where CT2_FILIAL between @cFilial_CT2 and @IN_FILIALATE
            and CT2_DATA   between @IN_DATADE   and @IN_DATAATE
            and CT2_TPSALD   = @IN_TPSALDO
            and CT2_DC       != '4'
            and ((CT2_MOEDLC = @IN_MOEDA AND @IN_LMOEDAESP = '1') OR @IN_LMOEDAESP = '0')
            and D_E_L_E_T_ = ' '
    GROUP BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_DC, CT2_MOEDLC
    ORDER BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC,CT2_DC, CT2_MOEDLC
    for read only
    open CUR_CT190DOC
    Fetch CUR_CT190DOC Into @cFILCT2, @cCT2_DC, @cCT2_DATA, @cCT2_LOTE, @cCT2_SBLOTE, @cCT2_DOC, @cCT2_MOEDLC, @nCT2_VALOR
   
    While (@@fetch_status = 0) begin
          
        If @cFirst = '0' OR @cFilCTCAnt !=  @cFILCT2 begin
            select @cFirst = '1'         
            select @cAux = 'CTC'         
            exec XFILIAL_## @cAux, @cFILCT2, @cFilial_CTC OutPut
        End
      
        Select @nCTC_DEBITOX = 0
        Select @nCTC_CREDITX = 0
        Select @nCTC_DIGX    = 0
        select @nCTC_DIG     = 0
        select @nCTC_DEBITO  = 0
        select @nCTC_CREDIT  = 0
        select @nCTC_INF     = 0
        select @nCT2_VALOR   = @nCT2_VALOR
        
         /* --- Trata @IN_MV_SOMA -----*/
        if @cCT2_DC IN ('1','3') begin
            select @nCTC_DEBITOX = Round(@nCT2_VALOR, 2)
        end
        if @cCT2_DC IN ('2','3') begin
            select @nCTC_CREDITX = Round(@nCT2_VALOR, 2)
        end
        If @cCT2_DC = '3' begin
            If @IN_MVSOMA = '1' begin 
                Select @nCTC_DIGX = Round(@nCT2_VALOR, 2)
            end else Select @nCTC_DIGX = Round(( 2 * @nCT2_VALOR ), 2)
        end else Select @nCTC_DIGX = Round(@nCT2_VALOR, 2)
              
        /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
            -------------------------------------------------------------------------------------------------------------- */
        select @iRecno  = 0
        ##UNIQUEKEY_START
        Select @iRecno = IsNull( MIN(R_E_C_N_O_),0 )
          From CTC###
         Where CTC_FILIAL = @cFilial_CTC
           and CTC_DATA   = @cCT2_DATA
           and CTC_LOTE   = @cCT2_LOTE
           and CTC_SBLOTE = @cCT2_SBLOTE
           and CTC_DOC    = @cCT2_DOC
           and CTC_MOEDA  = @cCT2_MOEDLC
           and CTC_TPSALD = @IN_TPSALDO
           and D_E_L_E_T_ = ' '
        ##UNIQUEKEY_END
                   
        If @iRecno = 0 begin
            /* --------------------------------------------------------------------------
            Recupera o R_E_C_N_O_ para ser gravado
            -------------------------------------------------------------------------- */
            select @iRecno = Isnull(MAX(R_E_C_N_O_), 0) FROM CTC###
            select @iRecno = @iRecno + 1
            /*---------------------------------------------------------------
            Insercao / Atualizacao CTC
            --------------------------------------------------------------- */
            ##TRATARECNO @iRecno\
            Begin Tran
            Insert into CTC### ( CTC_FILIAL, CTC_MOEDA,  CTC_TPSALD,  CTC_DATA,   CTC_LOTE,  CTC_SBLOTE, CTC_DOC,   CTC_STATUS, CTC_DEBITO, CTC_CREDIT, CTC_DIG, R_E_C_N_O_ )
                        values( @cFilial_CTC,@cCT2_MOEDLC, @IN_TPSALDO, @cCT2_DATA, @cCT2_LOTE, @cCT2_SBLOTE, @cCT2_DOC,   '1',          0,          0,       0, @iRecno  )
         
            Commit Tran
            ##FIMTRATARECNO
        end
        
        Begin tran
        Update CTC###
        Set CTC_DEBITO = CTC_DEBITO + @nCTC_DEBITOX, CTC_CREDIT = CTC_CREDIT + @nCTC_CREDITX, CTC_DIG = CTC_DIG +  @nCTC_DIGX
        Where R_E_C_N_O_ = @iRecno
        Commit Tran

        select @cFilCTCAnt = @cFILCT2
        SELECT @fim_CUR = 0
        Fetch CUR_CT190DOC Into @cFILCT2, @cCT2_DC, @cCT2_DATA, @cCT2_LOTE, @cCT2_SBLOTE, @cCT2_DOC, @cCT2_MOEDLC, @nCT2_VALOR
    End
    Close CUR_CT190DOC
    Deallocate CUR_CT190DOC
    /*---------------------------------------------------------------
        Se a execucao foi OK retorna '1'
    --------------------------------------------------------------- */
    select @OUT_RESULTADO = '1'
end
