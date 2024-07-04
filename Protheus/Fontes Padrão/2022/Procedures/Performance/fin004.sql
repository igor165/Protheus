Create Procedure FIN004_##
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
   @IN_PCCBAIXA  Char(01),
   @IN_CART      Char(01),
   @IN_ADIANT    Char( 01 ),
   @IN_IRFBAIXA  Char(01),
   @IN_ISSBAIXA  Char(01),
   @IN_FILIALORI Char('E5_FILORIG'), 
   @OUT_VALOR    Float  Output
 )

as
/* ---------------------------------------------------------------------
      Procedure    -  <d> Recupera o saldo do titulo na determinada data para BRASIL</d>
      Versão       - <v> Protheus P11 </v>
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
                            @IN_PCCBAIXA    - Motivo baixa =  'PCC'
                            @IN_CART        - Carteira - R - Pagar, P - Pagar
                            @IN_ADIANT      - '1' se Adiantamento, senao '0'  
						    @IN_FILIALORI   - Filial do Titulo de origem </ri>
      Saida          -  <ro> @OUT_SALDO       - Saldo do titulo </ro>
      Autor          :  <r> Vicente Sementilli </r>
      Criacao       :  <dt> 28/07/1998 </dt>

 Alterações : Retirado o filtro da coluna E5_NATUREZ porque existe 
            movimento com natureza diferente do Tit.Principal

 ---------------------------------------------------------------------- */
declare @nSaldoMovto  Float
declare @nSaldoTitulo Float
declare @nDesconto    Float
declare @nMulta       Float
declare @nJuros       Float
declare @nAcrescimo   Float
declare @nDecrescimo  Float
declare @nRetPis      Float
declare @nRetCof      Float
declare @nRetCsll     Float
declare @nRetIrf      Float
declare @nRetIss	  Float
declare @dBaixa       Char(08)
declare @iPos         Integer
declare @nAux         integer
declare @cCart        Char(01)

Begin
   select @OUT_VALOR = 0
   select @nSaldoTitulo = @IN_VALORTIT
   /* ------------------------------------------------------------------------------
      Inverte a carteira. Variavel auxiliar
      ------------------------------------------------------------------------------ */
   select @cCart    = @IN_CART
   If @IN_ADIANT   = '1' begin
      If @IN_CART = 'P' select @cCart = 'R'
      else select @cCart = 'P'
   End
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
   select @nAcrescimo = 0
   select @nDecrescimo = 0
   
   select @nSaldoMovto = IsNull(Sum(A.E5_VALOR),0),   @nDesconto = IsNull(Sum(A.E5_VLDESCO),0),
          @nMulta      = IsNull(Sum(A.E5_VLMULTA),0), @nJuros    = IsNull(Sum(A.E5_VLJUROS),0),
          @nAcrescimo  = IsNull(Sum(A.E5_VLACRES),0), @nDecrescimo = IsNull(Sum(A.E5_VLDECRE),0) 
     from SE5### A
    where A.E5_FILIAL   = @IN_FILIALE5
      and A.E5_PREFIXO  = @IN_PREFIXO
      and A.E5_NUMERO   = @IN_NUMERO
      and A.E5_PARCELA  = @IN_PARCELA
      and A.E5_TIPO     = @IN_TIPO
      and A.E5_CLIFOR   = @IN_CLIFOR
      and A.E5_LOJA     = @IN_LOJA
	  and A.E5_FILORIG  = @IN_FILIALORI
      and (   (A.E5_DATA    <= @dBaixa and @IN_DISPONI = '0')
           or (A.E5_DTDISPO <= @dBaixa and @IN_DISPONI = '1')
           or (A.E5_DTDIGIT <= @dBaixa and @IN_DISPONI = '2')  )
      and ( A.E5_SITUACA <> 'C' or A.E5_DTCANBX > @dBaixa )
      and A.E5_TIPODOC in ('VL','BA','V2','CP','LJ')

	  ##FIELDP01( 'SE5.E5_ORIGEM' )
	     and NOT(A.E5_TIPODOC = 'VL' and A.E5_ORIGEM = 'LOJXREC ' AND @cCart  = 'R')
    
	  ##ENDFIELDP01

      and ((A.E5_RECPAG   = @cCart) OR (A.E5_RECPAG = @IN_CART AND E5_DOCUMEN != ' ' ))
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
   
   /* ------------------------------------------------------------------------------
      Converte o saldo do movimento para a moeda do titulo
      @OUT_VALOR = @nSaldoTitulo - @nSaldoMovto
      ------------------------------------------------------------------------------ */
   select @nSaldoMovto = (@nSaldoMovto - ((@nJuros - @nAcrescimo) + @nMulta)) + (@nDesconto - @nDecrescimo)
   select @nAux = 1
   ##FIELDP02( 'SE5.E5_VRETPIS;SE5.E5_VRETCOF;SE5.E5_VRETCSL;SE5.E5_VRETIRF;SE5.E5_VRETISS' )
   if (@IN_PCCBAIXA = '1' or @IN_IRFBAIXA = '1' or @IN_ISSBAIXA = '1') and (@IN_CART = 'P') 
   begin

      select @nRetPis  = IsNull(Sum(A.E5_VRETPIS),0)
           , @nRetCof = IsNull(Sum(A.E5_VRETCOF),0)
           , @nRetCsll = IsNull(Sum(A.E5_VRETCSL),0)
		     , @nRetIrf = IsNull(Sum(A.E5_VRETIRF),0)
		     , @nRetIss = IsNull(Sum(A.E5_VRETISS),0)
        from SE5### A
       where A.E5_FILIAL   = @IN_FILIALE5
         and A.E5_PREFIXO  = @IN_PREFIXO
         and A.E5_NUMERO   = @IN_NUMERO
         and A.E5_PARCELA  = @IN_PARCELA
         and A.E5_TIPO     = @IN_TIPO
         and A.E5_CLIFOR   = @IN_CLIFOR
         and A.E5_LOJA     = @IN_LOJA
         and ( A.E5_VRETPIS + A.E5_VRETCOF + A.E5_VRETCSL  ) > 0  and  A.E5_MOTBX <> 'PCC'
         and (   (A.E5_DATA    <= @dBaixa and @IN_DISPONI = '0')
              or (A.E5_DTDISPO <= @dBaixa and @IN_DISPONI = '1')
              or (A.E5_DTDIGIT <= @dBaixa and @IN_DISPONI = '2')  )
         and ( A.E5_SITUACA <> 'C' or A.E5_DTCANBX > @dBaixa )
         and A.E5_TIPODOC in ('VL','BA','V2','CP','LJ')

		 ##FIELDP03( 'SE5.E5_ORIGEM' )
		    and NOT(A.E5_TIPODOC = 'VL' and A.E5_ORIGEM = 'LOJXREC ' AND @cCart  = 'R')
    
		 ##ENDFIELDP03

         and ((A.E5_RECPAG   = @cCart) OR (A.E5_RECPAG = @IN_CART AND E5_DOCUMEN != ' ' ))
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
                     and ( B.E5_VRETPIS + B.E5_VRETCOF + B.E5_VRETCSL  ) > 0  and  B.E5_MOTBX <> 'PCC'
                     and (    (B.E5_DATA    <= @IN_DATABASE and @IN_DISPONI = '0')
                           or (B.E5_DTDISPO <= @IN_DATABASE and @IN_DISPONI = '1') 
                           or (B.E5_DTDIGIT <= @IN_DATABASE and @IN_DISPONI = '2')    )
                     and B.D_E_L_E_T_ = ' ')
 
      select @nSaldoMovto = @nSaldoMovto + @nRetPis  + @nRetCof + @nRetCsll + @nRetIrf + @nRetIss
      if (@nSaldoMovto < 0.009)  select @nSaldoMovto = 0
        
   end
   ##ENDFIELDP02
   exec MAT021_## @nSaldoMovto, @IN_CONVERSAO, @nAux, @IN_MOEDATIT, @nSaldoMovto Output
   select @OUT_VALOR = @nSaldoTitulo - @nSaldoMovto
   
   if @OUT_VALOR is Null select @OUT_VALOR = 0
End

