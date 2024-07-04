create procedure PCO003_##
( 
	@IN_FILIALCOR	Char('AKT_FILIAL'),
	@IN_CONFIG    	Char('AL1_CONFIG'),
	@IN_TIPOMOV    Char(01),
	@IN_DATA    	Char(08),
	@IN_DATAF   	Char(08),
	@IN_CHAVE      Char('AKT_CHAVE'),
	@IN_VALOR1   	float,
	@IN_VALOR2   	float,
	@IN_VALOR3   	float,
	@IN_VALOR4   	float,
	@IN_VALOR5   	float,
   @IN_TPSALD     Char('AKT_TPSALD'),
   @IN_NIV01      Char('AKT_NIV01'),
   @IN_NIV02      Char('AKT_NIV02'),
   @IN_NIV03      Char('AKT_NIV03'),
   @IN_NIV04      Char('AKT_NIV04'),
   @IN_NIV05      Char('AKT_NIV05'),
   @IN_NIV06      Char('AKT_NIV06'),
   @IN_ANALIT     Char('AKT_ANALIT'),
	@OUT_RESULTADO Char(01) OutPut
	
)
as

/* ---------------------------------------------------------------------------------------------------------------------
    Versão          - <v> Protheus P11 </v>
    Assinatura      - <a> 011 </a>
    Fonte Microsiga - <s> PCOXSLD.PRX </s>
    Descricao       - <d> Atualiza os saldos dos cubos nas datas posteriores ao movimento  </d>
    Funcao do Siga  -     PcoWriteSld()
    -----------------------------------------------------------------------------------------------------------------
    Entrada         -  <ri> @IN_FILIALCOR	- Filial corrente 
       				   		@IN_CONFIG    	- Codigo do cubo
         						@IN_TIPOMOV		- Tipo de movimento (C=Credito;D=Debito) 
         						@IN_DATA    	- Data do movimento
         						@IN_DATAF    	- Ultimo dia do mes da data do movimento
         						@IN_CHAVE  		- Chave do cubo
         						@IN_VALOR1   	- Valor na moeda 1
         						@IN_VALOR2   	- Valor na moeda 2
         						@IN_VALOR3   	- Valor na moeda 3
         						@IN_VALOR4    	- Valor na moeda 4
         						@IN_VALOR5   	- Valor na moeda 5
                           @IN_TPSALD     - Tipo do Saldo
                           @IN_NIV01      - Chave do Nivel 01
                           @IN_NIV02      - Chave do Nivel 02
                           @IN_NIV03      - Chave do Nivel 03
                           @IN_NIV04      - Chave do Nivel 04
                           @IN_NIV05      - Chave do Nivel 05
                           @IN_NIV06      - Chave do Nivel 06
         						@IN_ANALIT   	- "1" indica que e analitico 	</ri>
    -----------------------------------------------------------------------------------------------------------------
    Saida       :  <ro> Sem saida </ro>
    -----------------------------------------------------------------------------------------------------------------
    Versão      :  <v> Advanced Protheus </v>
    -----------------------------------------------------------------------------------------------------------------
    Observações :  <o>   </o>
    -----------------------------------------------------------------------------------------------------------------
    Responsavel :   <r> Alice Yaeko Yamamoto  </r>
    -----------------------------------------------------------------------------------------------------------------
    Data        :  <dt> 29/04/2008 </dt>

    Estrutura de chamadas
    ========= == ========

    0.PCO003 - Atualiza os saldos dos cubos

    -----------------------------------------------------------------------------------------------------------------
    Obs.: Não remova os tags acima. Os tags são a base para a geração automática, de documentação, pelo Parse.
   --------------------------------------------------------------------------------------------------------------------- */
Declare @cFil_AKT  Char('AKT_FILIAL')
Declare @cAux      Char(03)
Declare @iRecnoAKT Integer
Declare @iRecno    Integer
Declare @nValor1   Float
Declare @nValor2   Float
Declare @nValor3   Float
Declare @nValor4   Float
Declare @nValor5   Float
Declare @Out_Res   char(01)

begin
   select @OUT_RESULTADO = '0'
   select @Out_Res = '0'
   /* --------------------------------------------------------------
      Recuperando Filiais
      -------------------------------------------------------------- */
   select @cAux = 'AKT'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_AKT OutPut
   
   select @nValor1 = @IN_VALOR1
   select @nValor2 = @IN_VALOR2
   select @nValor3 = @IN_VALOR3
   select @nValor4 = @IN_VALOR4
   select @nValor5 = @IN_VALOR5
   select @iRecnoAKT = null
   /* --------------------------------------------------------------
      Atualizacao de credito
      -------------------------------------------------------------- */
   if @IN_TIPOMOV = 'C' begin
      /* --------------------------------------------------------------
         Atualizacao de Credito do dia - AKT
         -------------------------------------------------------------- */
      /* ---------------------------------------------------------------
         As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
         houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
         após a MsParse() devolver o código na linguagem do banco em uso.
            -------------------------------------------------------------------------------------------------------------- */
      select @iRecnoAKT = 0 
      ##UNIQUEKEY_START
      Select @iRecnoAKT = IsNull(Min( R_E_C_N_O_ ), 0)
        From AKT###
       where AKT_FILIAL = @cFil_AKT
			and AKT_CONFIG = @IN_CONFIG
			and AKT_CHAVE  = @IN_CHAVE
			and AKT_DATA	= @IN_DATA
     		and D_E_L_E_T_ = ' '
      ##UNIQUEKEY_END

      If @iRecnoAKT = 0 begin
         select @iRecnoAKT = IsNull(Max(R_E_C_N_O_), 0) FROM AKT###
         select @iRecnoAKT = @iRecnoAKT + 1
         ##TRATARECNO @iRecnoAKT\
         begin tran
         insert into AKT### (	AKT_FILIAL, AKT_CHAVE, AKT_DATA,  AKT_CONFIG, AKT_MVCRD1, AKT_MVCRD2, AKT_MVCRD3, AKT_MVCRD4, AKT_MVCRD5,
                              AKT_TPSALD, AKT_NIV01, AKT_NIV02, AKT_NIV03,  AKT_NIV04,  AKT_NIV05,  AKT_NIV06,  AKT_ANALIT, R_E_C_N_O_ )
                      values( @cFil_AKT,  @IN_CHAVE, @IN_DATA,  @IN_CONFIG, 0        ,  0        ,  0        ,  0         ,   0       ,
                              @IN_TPSALD, @IN_NIV01, @IN_NIV02, @IN_NIV03,  @IN_NIV04,  @IN_NIV05,  @IN_NIV06,  @IN_ANALIT,  @iRecnoAKT)
         commit tran
         ##FIMTRATARECNO
      end 

      begin tran
      Update AKT###
         Set AKT_MVCRD1 = AKT_MVCRD1+@nValor1, AKT_MVCRD2 = AKT_MVCRD2+@nValor2, AKT_MVCRD3 = AKT_MVCRD3+@nValor3, AKT_MVCRD4 =AKT_MVCRD4+@nValor4, AKT_MVCRD5 =AKT_MVCRD5+@nValor5
         Where R_E_C_N_O_ = @iRecnoAKT
      commit tran
      
	end else begin
      /* --------------------------------------------------------------
         Atualizacao de Debito do dia - AKT
         -------------------------------------------------------------- */
      /* ---------------------------------------------------------------
      As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
      houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
      após a MsParse() devolver o código na linguagem do banco em uso.
      -------------------------------------------------------------------------------------------------------------- */
      select @iRecnoAKT = 0 
      ##UNIQUEKEY_START
      Select @iRecnoAKT = IsNull(Min( R_E_C_N_O_ ), 0)
        From AKT###
       where AKT_FILIAL = @cFil_AKT
			and AKT_CONFIG = @IN_CONFIG
			and AKT_CHAVE  = @IN_CHAVE
			and AKT_DATA	= @IN_DATA
     		and D_E_L_E_T_ = ' '
      ##UNIQUEKEY_END
      
      If @iRecnoAKT = 0 begin
         select @iRecnoAKT = IsNull(Max(R_E_C_N_O_), 0) FROM AKT###
         select @iRecnoAKT = @iRecnoAKT + 1
         ##TRATARECNO @iRecnoAKT\
         begin tran
         insert into AKT### (	AKT_FILIAL, AKT_CHAVE, AKT_DATA,  AKT_CONFIG, AKT_MVDEB1, AKT_MVDEB2, AKT_MVDEB3, AKT_MVDEB4, AKT_MVDEB5,
                              AKT_TPSALD, AKT_NIV01, AKT_NIV02, AKT_NIV03,  AKT_NIV04,  AKT_NIV05,  AKT_NIV06,  AKT_ANALIT, R_E_C_N_O_ )
                      values( @cFil_AKT,  @IN_CHAVE, @IN_DATA,  @IN_CONFIG, 0        ,  0        ,  0        ,  0         , 0         ,
                              @IN_TPSALD, @IN_NIV01, @IN_NIV02, @IN_NIV03,  @IN_NIV04,  @IN_NIV05,  @IN_NIV06,  @IN_ANALIT, @iRecnoAKT )
         commit tran
         ##FIMTRATARECNO
      end  

      begin tran
      Update AKT###
         Set AKT_MVDEB1=AKT_MVDEB1+@nValor1, AKT_MVDEB2=AKT_MVDEB2+@nValor2, AKT_MVDEB3=AKT_MVDEB3+@nValor3, AKT_MVDEB4=AKT_MVDEB4+@nValor4, AKT_MVDEB5=AKT_MVDEB5+@nValor5
         Where R_E_C_N_O_ = @iRecnoAKT
      commit tran

	end
   select @OUT_RESULTADO = '1'
end
