Create procedure MAT043_##
(
   @IN_FILIALCOR    Char('B1_FILIAL'),
   @IN_COD          Char('B1_COD'),
   @IN_MV_NEGESTR   Char(01)      ,
   @OUT_RESULTADO   Char(01) Output
)
as
/* ---------------------------------------------------------------------------------------------------------------------
    Versão      - <v> Protheus P12 </v>
    Programa    - <s> A225ChgCus </s>
    Assinatura  - <a> 001 </a>
    Descricao   - <d> Verifica se pode alterar o custo medio do produto </d>
    Entrada     - <ri>
                   @IN_FILIALCOR    - Filial Corrente
                   @IN_CODO         - Codigo do Produto a ser recuperado o Custo
                   @IN_MV_NEGESTR   - Permite incluir itens com valor negativo na estrutura do produto
                   </ri>
    Saida         <ro> @OUT_RESULT      - Status da execucao do processo </ro>
    Responsavel : <r> Marco Norbiato </r>
    Data        : <dt> 14/03/2003 </dt>
--------------------------------------------------------------------------------------------------------------------- */
declare @cFil_SG1     char('G1_FILIAL')
declare @cFil_SB1     char('B1_FILIAL')
declare @cAux         varchar(03)
declare @nContador    int
declare @cB1_CCCUSTO  char('B1_CCCUSTO')
declare @cAxuCUSTO    char('B1_CCCUSTO')

begin

   select @cAxuCUSTO   = ##TAMSX3DIC_001('B1_CCCUSTO')##ENDTAMSX3DIC_001
   select @cB1_CCCUSTO = ##TAMSX3DIC_002('B1_CCCUSTO')##ENDTAMSX3DIC_002
   select @nContador  = 0

   select @cAux = 'SB1'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB1 OutPut

    /* ---------------------------------------------------------------------------------------------------------------
         Verifica se utiliza mao-de-obra atraves do campo B1_CCCUSTO
      --------------------------------------------------------------------------------------------------------------- */
	select @cB1_CCCUSTO = IsNull(B1_CCCUSTO,' ') 
	  from SB1### 
	 where B1_FILIAL   = @cFil_SB1 
	   and B1_COD      = @IN_COD
	   and D_E_L_E_T_  = ' '

   if ( substring( @IN_COD, 1, 3 ) <> 'MOD' ) and IsNull(@cB1_CCCUSTO,##TAMSX3DIC_003('B1_CCCUSTO')##ENDTAMSX3DIC_003) = @cAxuCUSTO  begin
      if ( @IN_MV_NEGESTR = '1' ) begin
         select @cAux = 'SG1'
         EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SG1 OutPut
         
         select @nContador = isnull( count(*), 0 )
           from SG1### SG1
          where G1_FILIAL  = @cFil_SG1
            and G1_COMP    = @IN_COD
            and G1_QUANT   < 0
            and D_E_L_E_T_ = ' '
      end
   end else select @nContador = 1
   
   if ( @nContador > 0 ) select @OUT_RESULTADO = '1'
   else                  select @OUT_RESULTADO = '0'
   
end
