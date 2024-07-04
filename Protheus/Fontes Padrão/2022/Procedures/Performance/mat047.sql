Create Procedure MAT047_##
 (
  @IN_FILIALCOR    Char('B1_FILIAL'),
  @IN_CALIASAVAL   Char( 03 ),
  @IN_CTES         Char('F4_CODIGO'),
  @IN_CESPECIE     Char( 05 ),
  @IN_CTIPODOC     Char( 02 ),
  @IN_CPAISLOC     Char( 03 ),
  @IN_DOC          Char('D1_DOC;D2_DOC'),
  @IN_SERIE        Char('D1_SERIE;D2_SERIE'),
  @IN_FORCLI       Char('D1_FORNECE;D2_CLIENTE'),
  @IN_LOJA         Char('D1_LOJA;D2_LOJA'),
  @IN_USAFILTRF    Char( 01 ),
  @OUT_RESULTADO   Char('B1_FILIAL') OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  MATA330.PRW </s>
    Descricao       - <d>  Verifica se o movimento eh de transferencia entre filiais </d>
    Funcao do Siga  -      M330TrFil()
    Entrada         - <ri> @IN_FILIAL     - Filial
                           @IN_CALIASAVAL -
                           @IN_CTES       -
                           @IN_CESPECIE   -
                           @IN_CTIPODOC   -
                           @IN_CPAISLOC   -
    Responsavel :     <r>  Marcelo Pimentel </r>
    Data        :     13/02/2007
-------------------------------------------------------------------------------------- */
Declare @iRecno          Integer
Declare @iRecnoSF1       Integer
Declare @iRecnoSF2       Integer
Declare @cFil_SF4        Char('F4_FILIAL')
Declare @cFil_SF1        Char('F1_FILIAL')
Declare @cFil_SF2        Char('F2_FILIAL')
Declare @cFil_SA1        Char('A1_FILIAL')
Declare @cFil_SA2        Char('A2_FILIAL')
Declare @cAux            Varchar(3)
Declare @cFilRet         Char('B1_FILIAL')
Declare @cCGC            Char('A1_CGC')
Declare @cCodFil         Char('A1_FILIAL')

Declare @cFILIALCOR    Char('B1_FILIAL')
Declare @cCTES         Char('F4_CODIGO')
Declare @cDOC          Char('D1_DOC;D2_DOC')
Declare @cSERIE        Char('D1_SERIE;D2_SERIE')
Declare @cFORCLI       Char('D1_FORNECE;D2_CLIENTE')
Declare @cLOJA         Char('D1_LOJA;D2_LOJA')

begin

  select @cFILIALCOR = @IN_FILIALCOR
  select @cCTES = @IN_CTES
  select @cDOC = @IN_DOC
  select @cSERIE = @IN_SERIE
  select @cFORCLI = @IN_FORCLI
  select @cLOJA = @IN_LOJA

   select @cAux = 'SF4'
   EXEC XFILIAL_## @cAux, @cFILIALCOR, @cFil_SF4 OutPut
   select @cAux = 'SF1'
   EXEC XFILIAL_## @cAux, @cFILIALCOR, @cFil_SF1 OutPut
   select @cAux = 'SF2'
   EXEC XFILIAL_## @cAux, @cFILIALCOR, @cFil_SF2 OutPut
   select @cAux = 'SA1'
   EXEC XFILIAL_## @cAux, @cFILIALCOR, @cFil_SA1 OutPut
   select @cAux = 'SA2'
   EXEC XFILIAL_## @cAux, @cFILIALCOR, @cFil_SA2 OutPut
   select @cFilRet = ' '

   -- Avalia se existe o campo no cadastro de TES
   ##FIELDP01( 'SF4.F4_TRANFIL' )
   select @iRecno = null
   select @iRecno = R_E_C_N_O_
     from SF4### (nolock)
    where F4_FILIAL  = @cFil_SF4
      and F4_CODIGO  = @cCTES
      and F4_TRANFIL = '1'
      and D_E_L_E_T_ = ' '

   if (@iRecno is not null) begin

      -- Tratamento para remito de transferencia RTS / RTE
      ##FIELDP02( 'SF2.F2_FILDEST;SF1.F1_FILORIG' )
      if @IN_CPAISLOC <> 'BRA' and @IN_CESPECIE in ('RTE','RTS') and @IN_CTIPODOC in ('54','64') begin

         if @IN_CALIASAVAL = 'SD2' begin
            select @cFilRet = ' '
            select @iRecnoSF2 = null
            select @iRecnoSF2 = SF2.R_E_C_N_O_,@cFilRet = SF2.F2_FILDEST
              from SF2### SF2 (nolock)
             where F2_FILIAL  = @cFil_SF2
               and F2_DOC     = @cDOC
               and F2_SERIE   = @cSERIE
               and F2_CLIENTE = @cFORCLI
               and F2_LOJA    = @cLOJA
               and D_E_L_E_T_ = ' '
         end else begin
           if ( @IN_CALIASAVAL = 'SD1' ) begin
              select @cFilRet = ' '
              select @iRecnoSF1 = null
              select @iRecnoSF1 = SF1.R_E_C_N_O_,@cFilRet = SF1.F1_FILORIG
                from SF1### SF1 (nolock)
               where F1_FILIAL  = @cFil_SF1
                 and F1_DOC     = @cDOC
                 and F1_SERIE   = @cSERIE
                 and F1_FORNECE = @cFORCLI
                 and F1_LOJA    = @cLOJA
                 and D_E_L_E_T_ = ' '
           end
         end
      end else begin
      ##ENDFIELDP02
		 if ( @IN_USAFILTRF = '1' ) begin
			##FIELDP03( 'SA1.A1_FILTRF;SA2.A2_FILTRF' )
             -- Utiliza os campos A1_FILTRF e A2_FILTRF
	         -- Itens da nota fiscal de entrada
	         if @IN_CALIASAVAL = 'SD1' begin
	            if @IN_CTIPODOC in ('D','B') begin
	               select @cCodFil = ' '
	               select @cCodFil = SA1.A1_FILTRF
	                 from SA1### SA1 (nolock)
	                where A1_FILIAL  = @cFil_SA1
	                  and A1_COD     = @cFORCLI
	                  and A1_LOJA    = @cLOJA
	                  and D_E_L_E_T_ = ' '
	            end else begin
	               select @cCodFil = ' '
	               select @cCodFil = SA2.A2_FILTRF
	                 from SA2### SA2 (nolock)
	                where A2_FILIAL  = @cFil_SA2
	                  and A2_COD     = @cFORCLI
	                  and A2_LOJA    = @cLOJA
	                  and D_E_L_E_T_ = ' '
	            end
	         -- Itens da nota fiscal de saida
	         end else begin
	            if ( @IN_CALIASAVAL = 'SD2' ) begin
	               if @IN_CTIPODOC in ('D','B') begin
	                  select @cCodFil = ' '
	                  select @cCodFil = SA2.A2_FILTRF
	                    from SA2### SA2 (nolock)
	                   where A2_FILIAL  = @cFil_SA2
	                     and A2_COD     = @cFORCLI
	                     and A2_LOJA    = @cLOJA
	                     and D_E_L_E_T_ = ' '
	               end else begin
	                  select @cCodFil = ' '
	                  select @cCodFil = SA1.A1_FILTRF
	                    from SA1### SA1 (nolock)
	                   where A1_FILIAL  = @cFil_SA1
	                     and A1_COD     = @cFORCLI
	                     and A1_LOJA    = @cLOJA
	                     and D_E_L_E_T_ = ' '
	               end
	            end
	         end
	      ##ENDFIELDP03
	         if ( @cCodFil <> ' ' ) begin
	            -- Checa se cliente / fornecedor estao configurados como filial do sistema
	            select @cFilRet = ' '
	            select @cFilRet = TRD.TRD_FILIAL
	              from TRD### TRD (nolock)
	             where TRD_FILIAL = @cCodFil
	               and D_E_L_E_T_ = ' '
	         end
         end else begin
	         -- Utiliza os campos A1_CGC e A2_CGC (por padrao)
	         -- Itens da nota fiscal de entrada
	         if @IN_CALIASAVAL = 'SD1' begin
	            if @IN_CTIPODOC in ('D','B') begin
	               select @cCGC = ' '
	               select @cCGC = SA1.A1_CGC
	                 from SA1### SA1 (nolock)
	                where A1_FILIAL  = @cFil_SA1
	                  and A1_COD     = @cFORCLI
	                  and A1_LOJA    = @cLOJA
	                  and D_E_L_E_T_ = ' '
	            end else begin
	               select @cCGC = ' '
	               select @cCGC = SA2.A2_CGC
	                 from SA2### SA2 (nolock)
	                where A2_FILIAL  = @cFil_SA2
	                  and A2_COD     = @cFORCLI
	                  and A2_LOJA    = @cLOJA
	                  and D_E_L_E_T_ = ' '
	            end
	         -- Itens da nota fiscal de saida
	         end else begin
	            if ( @IN_CALIASAVAL = 'SD2' ) begin
	               if @IN_CTIPODOC in ('D','B') begin
	                  select @cCGC = ' '
	                  select @cCGC = SA2.A2_CGC
	                    from SA2### SA2 (nolock)
	                   where A2_FILIAL  = @cFil_SA2
	                     and A2_COD     = @cFORCLI
	                     and A2_LOJA    = @cLOJA
	                     and D_E_L_E_T_ = ' '
	               end else begin
	                  select @cCGC = ' '
	                  select @cCGC = SA1.A1_CGC
	                    from SA1### SA1 (nolock)
	                   where A1_FILIAL  = @cFil_SA1
	                     and A1_COD     = @cFORCLI
	                     and A1_LOJA    = @cLOJA
	                    and D_E_L_E_T_ = ' '
	               end
	            end
	         end
	         if ( @cCGC <> ' ' ) begin
	            -- Checa se cliente / fornecedor estao configurados como filial do sistema
	            select @cFilRet = ' '
	            select @cFilRet = TRD.TRD_FILIAL
	              from TRD### TRD (nolock)
	             where TRD_CGC = @cCGC
	               and D_E_L_E_T_ = ' '
	         end
         end
      ##FIELDP04( 'SF2.F2_FILDEST;SF1.F1_FILORIG' )
      end
      ##ENDFIELDP04
   end

   ##ENDFIELDP01

	select @OUT_RESULTADO = IsNull(@cFilRet,' ')

End
