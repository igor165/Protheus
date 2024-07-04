CREATE PROCEDURE MAT008_##
(
   @IN_FILIALCOR   Char('B1_FILIAL'),
   @IN_PRODUTO     Char('B1_COD'),
   @IN_MV_PAR11    Integer,
   @OUT_RESULTADO  Char(01)  OUTPUT
)

as
/* ---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus 12 </v>
    Programa    -  <s> A330EST </s>
    Assinatura  -  <a> 001 </a>
    Descricao   -  <d> Verifica se DEVE considerar o produto como tendo estrutura </d>
    Entrada     -  <ri>
                   @IN_FILIALCOR    - Filial Corrente
                   @IN_PRODUTO      - Produto a ser testado se tem estrutura
                   @IN_MV_PAR11     - Parametro recebida da pergunte MTA33 no inicio do MATA330
                   </ri>
    Responsavel :  <r> Marco Norbiato </r>
    Data        :  <dt> 27/03/2000 </dt>
<o> Uso         :  MATA330 </o>
----------------------------------------------------------------------------- */
declare @cFil_SC2  char('C2_FILIAL')
declare @cFil_SG1  char('G1_FILIAL')
declare @vContador integer
declare @cAux      Varchar(3)

begin
   select @cAux = 'SC2'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SC2 OutPut
   select @cAux = 'SG1'
   EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SG1 OutPut

   select @vContador = 0

   if (@IN_MV_PAR11 = 1)
      select @vContador = Count(*)
        from SC2### SC2 (nolock)
       where C2_FILIAL     =  @cFil_SC2
         and C2_PRODUTO    =  @IN_PRODUTO
         and D_E_L_E_T_    =  ' '
   else
      select @vContador = Count(*)
        from SG1### (nolock)
       where G1_FILIAL  =  @cFil_SG1
         and G1_COD     =  @IN_PRODUTO
         and D_E_L_E_T_ =  ' '

   if @vContador > 0
      select @OUT_RESULTADO = '1'
   else
      select @OUT_RESULTADO = '0'
end
