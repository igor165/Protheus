CREATE PROCEDURE MAT015_##
(
 @IN_FILIALCOR   Char('B2_FILIAL'),
 @IN_MV_PAR11    integer,
 @IN_MV_NIVALT   Char(01),
 @IN_MV_CQ       Char('B2_LOCAL'),
 @IN_TAM_TRB_DOC Integer,
 @IN_MV_PAR18    integer
)
as
/* -------------------------------------------------------------------------------------------------------------
   Versão     : <v> Protheus 12 </v>
   -------------------------------------------------------------------------------------------------------------
   Programa   : <s> MA330NIVCD </s>
   -------------------------------------------------------------------------------------------------------------
   Descricao  : <d> Grava os niveis TRB_NIVEL / TRB_NIVSD3 referentes ao SC2 ou SG1 no TRB </d>
   -------------------------------------------------------------------------------------------------------------
   Assinatura : <a> 001 </a>
   -------------------------------------------------------------------------------------------------------------
   Entrada    : <ri> @IN_FILIALCOR  - Filial Corrente
                    @IN_MV_PAR11   - Gera estrutura por movimentos
                    @IN_MV_NIVALT  - Define se teve ou nao alteracoes na estrutura.
                    @IN_MV_CQ      - Local(Almoxarifado) Controle de Qualidade
                    @IN_TAM_TRB_DOC - Tamanho do campo Documento no arquivo de trabalho </ri>
   -------------------------------------------------------------------------------------------------------------
   Saida      : <ro> </ro>
   -------------------------------------------------------------------------------------------------------------
   Versão     : <v> Advanced Protheus </v>
   -------------------------------------------------------------------------------------------------------------
   Observações: <o> </o>
   -------------------------------------------------------------------------------------------------------------
   Responsavel: <r> Ricardo Gonçalves </r>
   -------------------------------------------------------------------------------------------------------------
   Data       : <dt> 24/06/2002 </dt>
   -------------------------------------------------------------------------------------------------------------
   Obs.: Não remova os tags acima. Os tags são a base para a geração, automática, de documentação.
   ------------------------------------------------------------------------------------------------------------- */

declare @cFil_SC2     char('C2_FILIAL')
declare @cFil_SG1     char('G1_FILIAL')
declare @cFil_SF4     char('F4_FILIAL')
declare @cC2_PRODUTO  char('C2_PRODUTO;B1_COD')
declare @cC2_NIVEL    char('C2_NIVEL')
declare @cTRB_OP      char('D3_OP')
declare @cTRB_COD     char('B1_COD')
declare @cTRB_CF      char('D3_CF')
declare @cTRB_SEQ     char('D3_NUMSEQ')
declare @dTRB_DTORIG  char(08)
declare @cTRB_DOC     char('D1_DOC;D2_DOC;D3_DOC')
declare @cTRB_LOCAL   char('B1_LOCPAD')
declare @cTRB_NIVEL   char('G1_NIV;D3_NIVEL')
declare @cTRB_NIVSD3  char(01)
declare @iTRB_RECSD1  integer
declare @cTRB_CHAVE   varchar('D3_OP+D1_FORNECE+D3_DOC+D2_SERIE+D3_NUMSEQ+D1_DTDIGIT+D3_CF+D3_NIVEL')
declare @cTRB_ALIAS   char(03)
declare @iTRB_RECNO   integer
declare @cTRB_ORDEM   char(03)
declare @cChaveNova   varchar('D3_OP+D1_FORNECE+D3_DOC+D2_SERIE+D3_NUMSEQ+D1_DTDIGIT+D3_CF+D3_NIVEL')
declare @cG1_NIV      varchar('G1_NIV;D3_NIVEL')
declare @cD1_OP       char('D1_OP')
declare @cF4_ESTOQUE  char('F4_ESTOQUE')
declare @cF4_PODER3   char('F4_PODER3')
declare @dD3_EMISSAO  Char('D3_EMISSAO')
declare @cD3_OP	      Char('D3_OP')
declare @cD3_CF       Char('D3_CF')
declare @cD3_NUMSEQ   Char('D3_NUMSEQ')

declare @iRecno	      integer
declare @iCqRecno     integer
declare @iNivel	      integer
declare @cNivSD3      char(01)
declare @lGrava	      char(01)
declare @cExecuteMta  char(01)
declare @cAux         Varchar(3)
declare @nAux         integer
declare @iTranCount   Integer --Var.de ajuste para SQLServer e Sybase -- Será trocada por Commit no CFGX051 após passar pelo Parse
declare @cD1_TES      char('D1_TES')
begin

   /* -----------------------------------------------------------------------------------------------------------
      Recuperando Filiais
      ----------------------------------------------------------------------------------------------------------- */
   select @cAux = 'SC2'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SC2 OutPut
   select @cAux = 'SG1'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SG1 OutPut
   select @cAux = 'SF4'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SF4 OutPut
   
   /* -----------------------------------------------------------------------------------------------------------
      Gerar estrutura temporária
     ------------------------------------------------------------------------------------------------------------ */
   if @IN_MV_PAR11 = 1 begin
      declare CUR_ESTRU_TMP insensitive cursor for
       Select TRB_OP, TRB_COD
         from TRB###
        where TRB_FILIAL = @IN_FILIALCOR
          and TRB_ALIAS  = 'SD3'
          and TRB_OP    <> ' '
          and TRB_CF  like '_E%'
      for read only
      
      open CUR_ESTRU_TMP
      
      fetch CUR_ESTRU_TMP into @cTRB_OP, @cTRB_COD
      
      while @@Fetch_Status = 0 begin
         
         select @cC2_PRODUTO = C2_PRODUTO
           from SC2### (nolock)
           where C2_FILIAL  = @cFil_SC2
             and C2_NUM	    = Substring( @cTRB_OP, 01, 6 )
             and C2_ITEM    = Substring( @cTRB_OP, 07, 2 )
             and C2_SEQUEN  = Substring( @cTRB_OP, 09, 3 )
             and C2_ITEMGRD = Substring( @cTRB_OP, 12, 2 )
             and D_E_L_E_T_ = ' '
         
         select @iRecno = Count(*)
           from TRB###SG1
          where G1_FILIAL = @IN_FILIALCOR
            and G1_COD    = @cC2_PRODUTO
            and G1_COMP   = @cTRB_COD
         
            Begin Tran
         if @iRecno = 0 begin
            insert into TRB###SG1 ( G1_FILIAL, G1_COMP,   G1_COD,       G1_FIM )
                           values ( @IN_FILIALCOR, @cTRB_COD, @cC2_PRODUTO, '19491231' )
         end
         Commit Tran
         fetch CUR_ESTRU_TMP into @cTRB_OP, @cTRB_COD
      end
      
      close CUR_ESTRU_TMP
      deallocate CUR_ESTRU_TMP
      /* ----------------------------------------------------------------------------------------------------------
         Acerta os niveis das estruturas no SG1TRB990
         ---------------------------------------------------------------------------------------------------------- */
      if ( @IN_MV_NIVALT is not null ) begin
         select @cExecuteMta = ''
         select @cAux = '1'
         EXEC MAT005_## @IN_FILIALCOR, @cAux, @cExecuteMta OUTPUT
      end
   end
   
   /* -------------------------------------------------------------------------------------------------------------
      Acertando nivel do arquivo de OP's
      ------------------------------------------------------------------------------------------------------------- */
   declare SC2_Cursor insensitive cursor for
   select DISTINCT C2_PRODUTO
     from SC2### SC2
    where SC2.C2_FILIAL  = @cFil_SC2
      and SC2.D_E_L_E_T_ = ' '
   For Read Only
   
   open  SC2_Cursor
   fetch SC2_Cursor into @cC2_PRODUTO
   
   while @@Fetch_Status = 0 begin
      
      -- seleciona todos os registros do SG1 para cada produto produzido
      select @cG1_NIV    = ' '
      if (@IN_MV_PAR11 = 1) begin
         declare TRBSG1_Cursor insensitive cursor for
         select G1_NIV
           from TRB###SG1
          where G1_FILIAL   = @IN_FILIALCOR
            and G1_COD      = @cC2_PRODUTO
            and D_E_L_E_T_  = ' '
         for read only
         
         open TRBSG1_Cursor
         fetch TRBSG1_Cursor into @cG1_NIV
         
         while @@Fetch_Status = 0 begin
            break
         end
         close TRBSG1_Cursor
         deallocate TRBSG1_Cursor
      end else begin
         declare SG1_Cursor cursor for
         select G1_NIV
           from SG1###
          where G1_FILIAL	 = @cFil_SG1
            and G1_COD 		 = @cC2_PRODUTO
            and D_E_L_E_T_  = ' '
         for read only
         open SG1_Cursor
         fetch SG1_Cursor into @cG1_NIV
         while @@Fetch_Status = 0 begin
            break
         end
         close SG1_Cursor
         deallocate SG1_Cursor
      end
      
      if @cG1_NIV is null
         select @cG1_NIV = ' '
      else begin
         if @cG1_NIV <> ' ' begin
            select @lGrava = '1'
            select @iNivel = 100 - Convert( integer, Substring(@cG1_NIV, 1, 2))
            select @nAux = 2
            exec MSSTRZERO @iNivel, @nAux, @cG1_NIV output
         end
      end
         begin Tran
      update SC2###
         set C2_NIVEL   = Substring(@cG1_NIV,1,2)
       where C2_FILIAL  = @cFil_SC2
         and C2_PRODUTO = @cC2_PRODUTO
         and D_E_L_E_T_ = ' '
      commit transaction
       fetch SC2_Cursor into @cC2_PRODUTO
   end
   close SC2_Cursor
   deallocate SC2_Cursor
   /* ------------------------------------------------------------------------------------------------------------
      Ordem para processamento do N¡vel do SD3
      "1" - RE6 / DE6
      "1" - RE6 / DE6 na rotina A330Estru para as transferencias do CQ
      "5" - PR0 / PR1
      "5" - RE1 / DE1
      "5" - RE4 / DE4 na rotina A330Estru
      "5" - RE5 / DE5 no caso de tratamento de poder de terceiros
      "5" - RE7 / DE7 na rotina A330Estru
      "7" - RE3 / DE3
      "9" - RE0 / DE0
      "9" - RE2 / DE2
      E' calculado n¡vel para RE5 e DE5 somente no caso de devolucao de poder de terceiros . O PI deve ter o custo
      processado no momento da producao da OP informada no SD1. Caso contrario estas sÆo processadas junto da NF de
      retorno de beneficiamento (SD1).
      ------------------------------------------------------------------------------------------------------------- */
      
   if ( @IN_MV_PAR11 = 1 )
      select @iRecno = count(R_E_C_N_O_) from TRB###SG1 (nolock)
   else
      select @iRecno = count(R_E_C_N_O_) from SG1### (nolock)
   
   if (@iRecno > 0) or (@IN_MV_PAR11 = 1) begin
      declare CUR_TRB insensitive cursor for
      select TRB_CHAVE, R_E_C_N_O_, TRB_ALIAS,  TRB_RECNO, TRB_ORDEM,	TRB_COD,  TRB_OP, 	
             TRB_CF,    TRB_SEQ,    TRB_DTORIG, TRB_DOC,   TRB_LOCAL,	TRB_NIVEL, TRB_NIVSD3,
             TRB_RECSD1
       from TRB### (nolock)
      open CUR_TRB
      
      fetch CUR_TRB into @cTRB_CHAVE, @iRecno,   @cTRB_ALIAS,  @iTRB_RECNO, @cTRB_ORDEM, @cTRB_COD,   @cTRB_OP,
                         @cTRB_CF,    @cTRB_SEQ, @dTRB_DTORIG, @cTRB_DOC,   @cTRB_LOCAL, @cTRB_NIVEL, @cTRB_NIVSD3,
                         @iTRB_RECSD1
      
      while @@Fetch_Status = 0 begin
         
         select @cG1_NIV    = ' '
         select @cC2_NIVEL  = ' '
         select @cNivSD3    = ' '
         select @lGrava	    = '0'
         select @cChaveNova = ' '
         
         if (@IN_MV_PAR11 = 1)
            select @cG1_NIV = min(substring(G1_NIV,1,2))
              from TRB###SG1
             where G1_FILIAL  = @IN_FILIALCOR
               and G1_COD     = @cTRB_COD
               and D_E_L_E_T_ = ' '
         else
            select @cG1_NIV = min(substring(G1_NIV,1,2))
              from SG1###
             where G1_FILIAL  = @cFil_SG1
               and G1_COD     = @cTRB_COD
               and D_E_L_E_T_ = ' '
         
         if @cG1_NIV is null
            select @cG1_NIV = ' '
         else begin
            select @lGrava = '1'
            if @cG1_NIV <> ' ' begin
               select @iNivel = 100 - Convert( integer, Substring(@cG1_NIV, 1, 2))
               select @nAux = 2
               exec MSSTRZERO @iNivel, @nAux, @cG1_NIV output
            end
         end
         
         /* -------------------------------------------------------------------------------------------------------
            Processa registros referente ao arquivo SD1
            ------------------------------------------------------------------------------------------------------- */
         if @cTRB_ALIAS = 'SD1' begin
            Select @cD1_OP = D1_OP, @cF4_ESTOQUE = F4_ESTOQUE, @cF4_PODER3 = F4_PODER3
              from SD1### SD1, SF4### SF4
             where SD1.R_E_C_N_O_  = @iTRB_RECNO
               and F4_FILIAL       = @cFil_SF4
               and F4_CODIGO       = D1_TES
               and SF4.D_E_L_E_T_  = ' '
            
            if (@cTRB_ORDEM = '300') and (@cF4_ESTOQUE = 'S') And (@cF4_PODER3 = 'D') begin
               
               select @lGrava = '1'
               if @cD1_OP <> ' ' begin
                  Select @cC2_NIVEL = C2_NIVEL
                    from SC2### (nolock)
                   where C2_FILIAL   = @cFil_SC2
                     and C2_NUM      = Substring( @cD1_OP, 01, 6 )
                     and C2_ITEM     = Substring( @cD1_OP, 07, 2 )
                     and C2_SEQUEN   = Substring( @cD1_OP, 09, 3 )
                     and C2_ITEMGRD  = Substring( @cD1_OP, 12, 2 )
                     and D_E_L_E_T_  = ' '
                  
                  select @cNivSD3 = '5'
                  select @cG1_NIV = @cC2_NIVEL
                  
                  Select @cD3_OP = D3_OP, @cD3_CF = D3_CF, @dD3_EMISSAO = D3_EMISSAO, @cD3_NUMSEQ = D3_NUMSEQ
                    from SD3### (nolock)
                   where R_E_C_N_O_ = @iTRB_RECSD1
                  
                  select @cChaveNova = @cD3_OP || substring(@cD3_CF, 2, 1) || @dD3_EMISSAO || @cD3_NUMSEQ
                  
                  if ( @cD3_CF in ( 'DE4','DE6','DE7' )) select @cChaveNova = @cChaveNova || '9y'
                  else select @cChaveNova = @cChaveNova || '0y'
               end else select @cG1_NIV = Substring(@cG1_NIV,1,2) || 'y'
            end
         end
         
         /* ------------------------------------------------------------------------------------------------------------
            Processa registros referente ao arquivo SD2
            ------------------------------------------------------------------------------------------------------------ */
         if @cTRB_ALIAS = 'SD2' and @cTRB_ORDEM = '300' begin
            Select @cF4_ESTOQUE = F4_ESTOQUE, @cF4_PODER3 = F4_PODER3
              from SD2### SD2, SF4### SF4
             where SD2.R_E_C_N_O_  = @iTRB_RECNO
               and F4_FILIAL 		 = @cFil_SF4
               and F4_CODIGO 		 = D2_TES
               and SF4.D_E_L_E_T_ = ' '
            
            If @cF4_ESTOQUE = 'S' and @cF4_PODER3 = 'R' begin
               select @lGrava = '1'
               
               select @cNivSD3 = '5'
               select @cG1_NIV = Substring(@cG1_NIV,1,2) || 'x'
            end
         end
         
         /* ------------------------------------------------------------------------------------------------------------
            Processa registros referente ao arquivo SD3
            ------------------------------------------------------------------------------------------------------------ */
         if @cTRB_ALIAS = 'SD3' begin
            
            if (@cTRB_OP <> ' ') and (Substring(@cTRB_CF,2,2) <> 'E3') and
               ((@cTRB_CF <> 'RE5') or ((@cTRB_CF = 'RE5') and (@cTRB_ORDEM = '300'))) begin
               select @lGrava = '1'
               
               Select @cC2_NIVEL = C2_NIVEL
                 from SC2### (nolock)
                where C2_FILIAL	  = @cFil_SC2
                  and C2_NUM      = Substring( @cTRB_OP, 01, 6 )
                  and C2_ITEM     = Substring( @cTRB_OP, 07, 2 )
                  and C2_SEQUEN   = Substring( @cTRB_OP, 09, 3 )
                  and C2_ITEMGRD  = Substring( @cTRB_OP, 12, 2 )
                  and D_E_L_E_T_  = ' '
               
               select @cG1_NIV = @cC2_NIVEL
               select @cNivSD3= '5'
               
               if (@cTRB_CF = 'RE5') and (@cTRB_ORDEM = '300') begin
                  
                  Select @cD3_OP = D3_OP, @cD3_CF = D3_CF, @dD3_EMISSAO = D3_EMISSAO, @cD3_NUMSEQ = D3_NUMSEQ
                    from SD3### (nolock)
                   where R_E_C_N_O_ = @iTRB_RECNO

                  Select @cF4_ESTOQUE = F4_ESTOQUE, @cF4_PODER3 = F4_PODER3
                    from SD1### SD1, SF4### SF4
                   where SD1.R_E_C_N_O_  = @iTRB_RECSD1
                     and F4_FILIAL       = @cFil_SF4
                     and F4_CODIGO       = D1_TES
                     and SF4.D_E_L_E_T_  = ' '
	
                  if (@cF4_ESTOQUE = 'S') And (@cF4_PODER3 = 'D') begin
                     select @cChaveNova = @cD3_OP || substring(@cD3_CF, 2, 1) || @dD3_EMISSAO || @cD3_NUMSEQ
                     if ( @cD3_CF in ( 'DE4','DE6','DE7' )) select @cChaveNova = @cChaveNova || '9z'
                     else select @cChaveNova = @cChaveNova || '0z'
                  end
               end
            end else if substring(@cTRB_CF, 2, 2) in ('E4', 'E7') begin
               exec MAT014_## @IN_FILIALCOR, @cTRB_COD,       @cTRB_SEQ,   @cTRB_DOC,
                              @dTRB_DTORIG,  @iTRB_RECNO,     @cTRB_CF,    @cTRB_CF,
                              @IN_MV_CQ,     @IN_TAM_TRB_DOC, @cTRB_LOCAL, @IN_MV_CQ,
                              @IN_MV_PAR11,  @cTRB_ORDEM,     @cTRB_NIVEL, @cTRB_ALIAS, @IN_MV_PAR18
               select @lGrava = '0'
            end else if substring(@cTRB_CF, 2, 2) <> 'E3' begin
               select @lGrava = '1'
               select @cNivSD3 = '9'
            end else begin
               select @lGrava = '1'
               select @cNivSD3 = '7'
            end
            
            if (substring( @cTRB_CF, 2, 2) = 'E6' ) begin
               if ( @cTRB_LOCAL = @IN_MV_CQ ) begin
                  exec MAT014_## @IN_FILIALCOR, @cTRB_COD,       @cTRB_SEQ,   @cTRB_DOC,
                                 @dTRB_DTORIG,  @iTRB_RECNO,     @cTRB_CF,    @cTRB_CF,
                                 @IN_MV_CQ,     @IN_TAM_TRB_DOC, @cTRB_LOCAL, @IN_MV_CQ,
                                 @IN_MV_PAR11,  @cTRB_ORDEM,     @cTRB_NIVEL, @cTRB_ALIAS, @IN_MV_PAR18
                  select @lGrava = '0'
               end else begin
                  if @IN_MV_PAR18 = 1  select @cNivSD3 = '1'
                  else select @cNivSD3 = '9'
                  
                  select @iCqRecno = 0
                  select @iCqRecno = count(*)
                    from TRB###
                   where TRB_FILIAL = @IN_FILIALCOR
                     and TRB_ALIAS = 'SD3'
                     and TRB_SEQ   = @cTRB_SEQ
                     and TRB_LOCAL = @IN_MV_CQ
                   
                  if ( @iCqRecno > 0 ) select @lGrava = '0'
                  else select @lGrava = '1'
               end
            end
         end
         
         IF ( ( @lGrava <> '0' )         and ( ( @cTRB_NIVEL  <> @cG1_NIV ) or
            ( @cTRB_NIVSD3 <> @cNivSD3 ) or ( @cTRB_CHAVE	<> @cChaveNova ))) begin
            If ( @cG1_NIV is null ) select @cG1_NIV  = ' '
            If ( @cNivSD3 is null ) select @cNivSD3 = ' '
            begin Tran
            if ( @cChaveNova	= ' ' ) begin
               update TRB###
                  set TRB_NIVEL  = @cG1_NIV,
                      TRB_NIVSD3 = @cNivSD3
                where R_E_C_N_O_ = @iRecno
            end else begin
               update TRB###
                  set TRB_NIVEL  = @cG1_NIV,
                      TRB_NIVSD3 = @cNivSD3,
                      TRB_CHAVE  = @cChaveNova
                where R_E_C_N_O_ = @iRecno
            end
            Commit Tran
         end
         
         fetch CUR_TRB into @cTRB_CHAVE, @iRecno,   @cTRB_ALIAS,  @iTRB_RECNO, @cTRB_ORDEM, @cTRB_COD,   @cTRB_OP,
                            @cTRB_CF,	   @cTRB_SEQ, @dTRB_DTORIG, @cTRB_DOC,	 @cTRB_LOCAL, @cTRB_NIVEL, @cTRB_NIVSD3,
                            @iTRB_RECSD1
      end
      Close CUR_TRB
      Deallocate CUR_TRB
         End
      end
