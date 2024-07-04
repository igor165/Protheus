Create Procedure FIN005_##
 (
   @IN_FILIALE5  Char('E5_FILIAL'),
   @IN_PREFIXO   Char('E5_PREFIXO'),
   @IN_NUMERO    Char('E5_NUMERO'),
   @IN_PARCELA   Char('E5_PARCELA'),
   @IN_TIPO      Char('E5_TIPO'),
   @IN_CLIFOR    Char('E5_CLIFOR'),
   @IN_CONVERSAO Char(08),
   @IN_BAIXA     Char(08),
   @IN_LOJA      Char('E5_LOJA'),
   @IN_DATABASE  Char(08),
   @IN_VALORTIT  Float,
   @IN_MOEDATIT  Float,
   @IN_DISPONI   Char(01),
   @IN_CART      Char(01),
   @IN_ADIANT    Char( 01 ),
   @IN_CPAISLOC  Char( 03 ) ,
   @IN_TXTIT     Float ,   
   @OUT_VALOR    Float  Output
 )

as
/* ---------------------------------------------------------------------
      Procedure    -  <d> Recupera o saldo do titulo na determinada data para BRASIL</d>
      Versão       - <v> Protheus P12 </v>
      Assinatura    - <a> 001 </a>
      Fonte Siga    -  <s> SaldoTit </s>
      Entrada       -  <ri>
                            @INF_FILIALE5   - Filial E5
                            @IN_PREFIXO     - Prefixo do titulo
                            @IN_NUMERO      - Numero 
                            @IN_PARCELA     - Parcela
                            @IN_TIPO        - Tipo 
                            @IN_CLIFOR      - Cliente ou Fornecedor
                            @IN_CONVERSAO   - Data de conversao
                            @IN_BAIXA       - Data da baixa
                            @IN_LOJA        - Loja
                            @IN_DATABASE    - Database
                            @IN_VALORTIT    - Valor do Titulo
                            @IN_MOEDATIT    - Moeda do Titulo
                            @IN_DISPONI     - se O, considero E5_DATA,
                                              se 1, considero E5_DTDISPO,
                                              Se 2, entao considero E5_DTDIGIT
                            @IN_CART        - 'P' - Carteira Pagar, 'R'- Carteira Recebers
                            @IN_ADIANT      - '1' se Adiantamento, senao '0'
                            @IN_CPAISLOC    - pais  </ri>
      Saida          -  <ro> @OUT_SALDO       - Saldo do titulo </ro>
      Autor          :  <r> Vicente Sementilli </r>
      Criacao       :  <dt> 28/07/1998 </dt>

 Alterações : Retirado o filtro da coluna E5_NATUREZ porque existe 
            movimento com natureza diferente do Tit.Principal

 ---------------------------------------------------------------------- */
declare @cBanco       char( 'E5_BANCO' )
declare @nE5_VALOR    Float
declare @nE5_VLMOED2  Float 
declare @nSaldoMovto  Float
declare @nSaldoTitulo Float
declare @nSaldoTitAux Float
declare @nDesconto    Float
declare @nMulta       Float
declare @nJuros       Float
declare @dBaixa       Char(08)
declare @iPos         Integer
declare @nAux         integer
declare @cCart        Char(01)
declare @cData        Char( 08 )
declare @cE5_Data     Char( 08 )
declare @nVlrDesc     Float
declare @nVlrMulta	  Float
declare @nVlrJuros    Float
declare @nVldMoed2    Float
declare @nValor       Float
declare @nTxMoeda     Float
declare @cE5_DtDigit  Char(08)
declare @cE5_DtDispo  Char(08)
declare @cMotBx       Char(03)
declare @cMoeda       Char(02)
declare @cTpDoc		  Char(02)
declare @cDtValid	  Char(08)
declare @nTxTit       Float
declare @cTipMov	  Char(03)

Begin
   select @OUT_VALOR = 0
   select @nSaldoTitulo = @IN_VALORTIT
   /* ------------------------------------------------------------------------------
      Inverte a carteira. Variavel auxiliar
      ------------------------------------------------------------------------------ */
   select @cCart = 'P'
   select @nTxTit = @IN_TXTIT
   If @IN_CART = 'P' select @cCart = 'R'
   /* ------------------------------------------------------------------------------
      Caso a data de baixa esteja vazia inicializo com a data base
      ------------------------------------------------------------------------------ */
   if @IN_BAIXA is null select @dBaixa = @IN_DATABASE
   else                 select @dBaixa = @IN_BAIXA
   
   /* ------------------------------------------------------------------------------
    Recupera dados da movimentacao
   ------------------------------------------------------------------------------ */
   select @nSaldoMovto = 0
   select @nDesconto = 0
   select @nMulta = 0
   select @nJuros = 0
   select @nVlrDesc  = 0 
   select @nVlrMulta  = 0 
   select @nVlrJuros  = 0 
   select @nE5_VALOR   = 0
   select @nE5_VLMOED2 = 0
   select @nValor = 0
   select @nTxMoeda = 0
   select @cTipMov = 'RA'
   
   IF @IN_CPAISLOC  = 'BRA'  begin
      select @nAux  = 1    
      select @nSaldoTitAux = 0
	   declare CUR_SUMSALDO_A insensitive cursor for
              
      select A.E5_VLMOED2, A.E5_VALOR,A.E5_VLDESCO, A.E5_VLMULTA , A.E5_VLJUROS , A.E5_DATA, A.E5_DTDIGIT, A.E5_DTDISPO,A.E5_MOTBX, A.E5_MOEDA, A.E5_TIPODOC, A.E5_TXMOEDA
       from SE5### A
      where A.E5_FILIAL   = @IN_FILIALE5
		  and A.E5_PREFIXO  = @IN_PREFIXO
		  and A.E5_NUMERO   = @IN_NUMERO
		  and A.E5_PARCELA  = @IN_PARCELA
		  and A.E5_TIPO     = @IN_TIPO
		  and A.E5_CLIFOR   = @IN_CLIFOR
		  and A.E5_LOJA     = @IN_LOJA
		  and (   (A.E5_DATA    <= @dBaixa and @IN_DISPONI = '0')
			   or (A.E5_DTDISPO <= @dBaixa and @IN_DISPONI = '1')
			   or (A.E5_DTDIGIT <= @dBaixa and @IN_DISPONI = '2')  )
		  and A.E5_SITUACA <> 'C'
		  and A.E5_TIPODOC in ('VL','BA','V2','CP','LJ')
		  and ((((A.E5_RECPAG = @IN_CART) OR (A.E5_RECPAG = @cCart)) and @IN_ADIANT = '1')
			   OR ((A.E5_RECPAG = @IN_CART) AND @IN_ADIANT = '0'))
		  and A.D_E_L_E_T_  = ' '
		  and 0 = (select count(*) 
					 from SE5### B
					where B.E5_FILIAL  = A.E5_FILIAL
					  and B.E5_PREFIXO = A.E5_PREFIXO
					  and B.E5_NUMERO  = A.E5_NUMERO
					  and B.E5_PARCELA = A.E5_PARCELA
					  and B.E5_TIPO    = A.E5_TIPO
					  and B.E5_CLIFOR  = A.E5_CLIFOR
					  and B.E5_LOJA    = A.E5_LOJA
					  and B.E5_SEQ     = A.E5_SEQ
					  and B.E5_TIPODOC = 'ES'
					  and (    (B.E5_DATA    <= @IN_DATABASE and @IN_DISPONI = '0')
							or (B.E5_DTDISPO <= @IN_DATABASE and @IN_DISPONI = '1') 
							or (B.E5_DTDIGIT <= @IN_DATABASE and @IN_DISPONI = '2')    )
					  and B.D_E_L_E_T_ = ' ')
	  for read only
	  open  CUR_SUMSALDO_A
	  fetch CUR_SUMSALDO_A into @nVldMoed2 , @nValor, @nVlrDesc , @nVlrMulta , @nVlrJuros , @cE5_Data, @cE5_DtDigit, @cE5_DtDispo, @cMotBx, @cMoeda, @cTpDoc, @nTxMoeda
		      
	  while (@@fetch_status = 0) begin
	  
		/* -------------------------------------------------------------------------------------------------------	
		Verifica se o movimentos de fatura, compensação e liquidação ocorreram em moeda estrangeira,
		para efeito de visualização nas consultas e relatórios (mesmo conceito da função "MovMoedEs" (FINXFIN.PRX)
		-------------------------------------------------------------------------------------------------------- */
		if @IN_DISPONI  = '0' begin
			select @cDtValid = @cE5_Data
		end else begin
			if @IN_DISPONI  = '1' begin
				select @cDtValid = @cE5_DtDispo
				end else begin
				select @cDtValid = @cE5_DtDigit 
			end
		end     
		
		if  @cMoeda > '01' AND ((@cTpDoc IN ('CP','BA') AND @cMotBx IN ('CMP')) OR (@cTpDoc IN ('BA') AND @cMotBx IN ('LIQ','FAT'))) begin
			if (@IN_CART = 'P' AND (@cDtValid >= '20180413' OR (@cDtValid >= '20171227' AND @cTpDoc = 'CP' AND @cMotBx IN ('CMP')))) OR  (@IN_CART = 'R' AND @cDtValid >= '20181129') begin
				select @nSaldoMovto = @nValor
			end else begin
				select @nSaldoMovto = @nVldMoed2
			end
		end else begin
			select @nSaldoMovto =@nVldMoed2
		end
	  
         /* -----------------------------------------------------------------
	      	Converte o saldo do movimento para a moeda do titulo
	     ----------------------------------------------------------------- */
         IF convert(integer,@cMoeda)  < '2'  begin
			if @nTxMoeda > 0 begin
				SELECT @nJuros = @nVlrJuros / @nTxMoeda
				SELECT @nMulta = @nVlrMulta / @nTxMoeda
				SELECT @nDesconto = @nVlrDesc / @nTxMoeda
			end else begin
				if @nTxTit > 0 begin
					SELECT @nJuros = @nVlrJuros   / @nTxTit 
					SELECT @nMulta = @nVlrMulta   / @nTxTit
					SELECT @nDesconto = @nVlrDesc / @nTxTit
				end
			end
         END
		 Else begin
			SELECT @nJuros = @nVlrJuros
			SELECT @nMulta = @nVlrMulta
			SELECT @nDesconto = @nVlrDesc
		 END
         /* ------------------------------------------------------------------------------
            Converte o saldo do movimento para a moeda do titulo
            @OUT_VALOR = @nSaldoTitulo - @nSaldoMovto
         ------------------------------------------------------------------------------ */
         select @nSaldoMovto  =  (@nSaldoMovto  - @nJuros  - @nMulta  + @nDesconto ) 
         select @nAux  = @IN_MOEDATIT 
         EXEC MAT021_## @nSaldoMovto , @IN_CONVERSAO , @nAux , @IN_MOEDATIT , @nSaldoMovto output 
         select @nSaldoTitAux = @nSaldoTitAux + @nSaldoMovto
				
	      fetch CUR_SUMSALDO_A into @nVldMoed2 , @nValor, @nVlrDesc , @nVlrMulta , @nVlrJuros , @cE5_Data, @cE5_DtDigit, @cE5_DtDispo, @cMotBx, @cMoeda, @cTpDoc, @nTxMoeda
      end
	   close      CUR_SUMSALDO_A
      deallocate CUR_SUMSALDO_A
      select @nSaldoMovto = @nSaldoTitAux
		    
   end else begin
      /* Se diferente de BRASIL */
      select @nAux  = 1    
      declare CUR_SUMSALDO_B insensitive cursor for 
      select A.E5_VLMOED2, A.E5_VALOR, A.E5_VLDESCO, A.E5_VLMULTA , A.E5_VLJUROS , A.E5_DATA, A.E5_BANCO, A.E5_MOEDA
       from SE5### A
      where A.E5_FILIAL   = @IN_FILIALE5
        and A.E5_PREFIXO  = @IN_PREFIXO
        and A.E5_NUMERO   = @IN_NUMERO
        and A.E5_PARCELA  = @IN_PARCELA
        and A.E5_TIPO     = @IN_TIPO
        and A.E5_CLIFOR   = @IN_CLIFOR
        and A.E5_LOJA     = @IN_LOJA
        and (   (A.E5_DATA    <= @dBaixa and @IN_DISPONI = '0')
	         or (A.E5_DTDISPO <= @dBaixa and @IN_DISPONI = '1')
	         or (A.E5_DTDIGIT <= @dBaixa and @IN_DISPONI = '2')  )
        and A.E5_SITUACA != 'C'
        and A.E5_TIPODOC in ('VL','BA','V2','CP','LJ')
        and ((((A.E5_RECPAG = @IN_CART) OR (A.E5_RECPAG = @cCart)) and @IN_ADIANT = '1')
	         OR ((A.E5_RECPAG = @IN_CART) AND @IN_ADIANT = '0'))
        and A.D_E_L_E_T_  = ' '
        and 0 = (select count(*) 
			       from SE5### B
			      where B.E5_FILIAL  = A.E5_FILIAL
			        and B.E5_PREFIXO = A.E5_PREFIXO
			        and B.E5_NUMERO  = A.E5_NUMERO
			        and B.E5_PARCELA = A.E5_PARCELA
			        and B.E5_TIPO    = A.E5_TIPO
			        and B.E5_CLIFOR  = A.E5_CLIFOR
			        and B.E5_LOJA    = A.E5_LOJA
			        and B.E5_SEQ     = A.E5_SEQ
			        and B.E5_TIPODOC = 'ES'
			        and (    (B.E5_DATA    <= @IN_DATABASE and @IN_DISPONI = '0')
					      or (B.E5_DTDISPO <= @IN_DATABASE and @IN_DISPONI = '1') 
					      or (B.E5_DTDIGIT <= @IN_DATABASE and @IN_DISPONI = '2')    )
			        and B.D_E_L_E_T_ = ' ')
	   for read only
      open  CUR_SUMSALDO_B
      fetch CUR_SUMSALDO_B into @nE5_VLMOED2, @nE5_VALOR, @nVlrDesc, @nVlrMulta, @nVlrJuros, @cE5_Data, @cBanco, @cMoeda
            
      while (@@fetch_status = 0) begin
          /* -----------------------------------------------------------------
            Converte o saldo do movimento para a moeda do titulo
            ----------------------------------------------------------------- */
         EXEC MAT021_## @nVlrJuros , @cE5_Data , @nAux , @IN_MOEDATIT , @nJuros output 
         EXEC MAT021_## @nVlrMulta , @cE5_Data , @nAux , @IN_MOEDATIT , @nMulta output 
         EXEC MAT021_## @nVlrDesc  , @cE5_Data , @nAux , @IN_MOEDATIT , @nDesconto output 
         /* ------------------------------------------------------------------------------
            Converte o saldo do movimento para a moeda do titulo
            @OUT_VALOR = @nSaldoTitulo - @nSaldoMovto
            ------------------------------------------------------------------------------ */        
		 IF ((@IN_CPAISLOC  = 'PER' OR @IN_CPAISLOC  = 'MEX' OR @IN_CPAISLOC  = 'COL' ) AND @cMoeda = '01' AND @IN_MOEDATIT > 1 ) BEGIN
			select @nSaldoMovto  = @nSaldoMovto  +  (@nE5_VLMOED2  - @nJuros  - @nMulta  + @nDesconto ) 
		 END ELSE BEGIN
			select @nSaldoMovto  = @nSaldoMovto + ( @nE5_VALOR  - @nJuros  - @nMulta  + @nDesconto )
		 END

		  IF (@IN_CPAISLOC  = 'PER' OR @IN_CPAISLOC  = 'MEX' OR @IN_CPAISLOC  = 'COL' OR @IN_CPAISLOC  = 'PAR' )   AND @IN_TIPO = @cTipMov AND  CAST(@cMoeda AS int) > 1 AND @IN_MOEDATIT = 1   begin 
			select @nAux = CAST(@cMoeda AS int)
			EXEC MAT021_## @nSaldoMovto , @cE5_Data , @nAux , @IN_MOEDATIT , @nSaldoMovto output 
		 END ELSE BEGIN
			 select @nAux  = @IN_MOEDATIT 
			 EXEC MAT021_## @nSaldoMovto , @IN_CONVERSAO , @nAux , @IN_MOEDATIT , @nSaldoMovto output
		 END
         
        		
         fetch CUR_SUMSALDO_B into @nE5_VLMOED2, @nE5_VALOR, @nVlrDesc, @nVlrMulta, @nVlrJuros, @cE5_Data, @cBanco, @cMoeda
      end
      close      CUR_SUMSALDO_B
      deallocate CUR_SUMSALDO_B
   End
   
   select @OUT_VALOR  = @nSaldoTitulo  - @nSaldoMovto
   IF @OUT_VALOR is null begin 
     SELECT @OUT_VALOR  = 0 
   END 
END
