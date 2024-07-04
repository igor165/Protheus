Create procedure CTB028_##
( 
   @IN_SLBASE    Char('CT7_SLBASE'),
   @IN_DTLP      Char('CT7_DTLP'),
   @IN_LP        Char('CT7_LP'),
   @IN_STATUS    Char('CT7_STATUS'),
   @IN_DEBITO    Float,
   @IN_CREDIT    Float,
   @IN_ATUDEB    Float,
   @IN_ATUCRD    Float,
   @IN_ANTDEB    Float,
   @IN_ANTCRD    Float,
   @IN_LPDEB     Float,
   @IN_LPCRD     Float,
   @IN_RECNO     Integer
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P.11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA190.PRW </s>
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  Update no CT7 </d>
    Funcao do Siga  -      
    Entrada         - <ri> @IN_SLBASE       - Saldo base
                           @IN_DTLP         - Data LP
                           @IN_LP           - LP
                           @IN_STATUS       - Status
                           @IN_DEBITO       - movito a debito
                           @IN_CREDIT       - movito a credito
                           @IN_ATUDEB       - Saldo atual a debito
                           @IN_ATUCRD       - Saldo atual a credito
                           @IN_ANTDEB       - sl ant a Debito
                           @IN_ANTCRD       - sl ant a Debito
                           @IN_LPDEB        - lp a debito
                           @IN_LPCRD        - lp a credito
                           @IN_RECNO        - nro do recno </ri>
    Saida           - <o>   </ro
    Responsavel :     <r>  Alice Yaeko Yamamoto	</r>
    Data        :     21/11/2003
-------------------------------------------------------------------------------------- */

   Declare @nDEBITO    Float
   Declare @nCREDIT    Float
   Declare @nATUDEB    Float
   Declare @nATUCRD    Float
   Declare @nANTDEB    Float
   Declare @nANTCRD    Float
   Declare @nLPDEB     Float
   Declare @nLPCRD     Float

begin
   
   select @nDEBITO  =  Round(@IN_DEBITO, 2)
   select @nCREDIT  =  Round(@IN_CREDIT, 2)
   select @nATUDEB  =  Round(@IN_ATUDEB, 2)
   select @nATUCRD  =  Round(@IN_ATUCRD, 2)
   select @nANTDEB  =  Round(@IN_ANTDEB, 2)
   select @nANTCRD  =  Round(@IN_ANTCRD, 2)
   select @nLPDEB   =  Round(@IN_LPDEB, 2)
   select @nLPCRD   =  Round(@IN_LPCRD, 2)
   
   Update CT7###
      set CT7_SLBASE = @IN_SLBASE, CT7_DTLP = @IN_DTLP,     CT7_LP = @IN_LP,         CT7_STATUS = @IN_STATUS,
          CT7_DEBITO = @nDEBITO,   CT7_CREDIT = @nCREDIT,   CT7_ATUDEB = @nATUDEB,   CT7_ATUCRD = @nATUCRD,
          CT7_ANTDEB = @nANTDEB,   CT7_ANTCRD = @nANTCRD,   CT7_LPDEB = @nLPDEB,     CT7_LPCRD =  @nLPCRD
     Where R_E_C_N_O_ = @IN_RECNO
   
end
