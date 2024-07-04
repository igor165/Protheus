Create procedure CTB030_##
( 
   @IN_SLBASE    Char('CT3_SLBASE'),
   @IN_DTLP      Char('CT3_DTLP'),
   @IN_LP        Char('CT3_LP'),
   @IN_STATUS    Char('CT3_STATUS'),
   @IN_DEBITO    Float,
   @IN_CREDIT    Float,
   @IN_ATUDEB    Float,
   @IN_ATUCRD    Float,
   @IN_ANTDEB    Float,
   @IN_ANTCRD    Float,
   @IN_LPDEB     Float,
   @IN_LPCRD     Float,
   @IN_SLCOMP    Char( 'CT3_SLCOMP' ),
   @IN_RECNO     Integer
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA190.PRW </s>
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  Update no CT3 </d>
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
                           @IN_SLCOMP       - flag sld compost
                           @IN_RECNO        - nro do recno </ri>
    Saida           - <o>   </ro
    Responsavel :     <r>  Alice Yaeko Yamamoto	</r>
    Data        :     28/11/2003
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
   
   Update CT3###
      set CT3_SLBASE = @IN_SLBASE, CT3_DTLP = @IN_DTLP,     CT3_LP = @IN_LP,         CT3_STATUS = @IN_STATUS,
          CT3_DEBITO = @nDEBITO,   CT3_CREDIT = @nCREDIT,   CT3_ATUDEB = @nATUDEB,   CT3_ATUCRD = @nATUCRD,
          CT3_ANTDEB = @nANTDEB,   CT3_ANTCRD = @nANTCRD,   CT3_LPDEB = @nLPDEB,     CT3_LPCRD =  @nLPCRD,
          CT3_SLCOMP = @IN_SLCOMP
    Where R_E_C_N_O_ = @IN_RECNO
   
end
