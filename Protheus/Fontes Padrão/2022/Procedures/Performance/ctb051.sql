Create procedure CTB051_##
( 
   @IN_DATA      Char(08),
   @IN_LP        Char('CTY_LP'),
   @IN_DTLP      Char('CTY_DTLP'),
   @IN_STATUS    Char('CTY_STATUS'),
   @IN_SLCOMP    Char('CTY_SLCOMP'),
   @IN_DEBITO    Float,
   @IN_CREDIT    Float,
   @IN_ANTDEB    Float,
   @IN_ANTCRD    Float,
   @IN_ATUDEB    Float,
   @IN_ATUCRD    Float,
   @IN_RECNO     Integer
 )
as
/* ------------------------------------------------------------------------------------
    Vers�o          - <v>  Protheus P11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  Ctba360.PRW </s>
    Procedure       -      Reprocessamento SigaCTB
    Descricao       - <d>  UPDATE no CTY </d>
    Funcao do Siga  -      
    Entrada         - <ri> @IN_DATA         - Data
                           @IN_LP           - Lucros e perdas
                           @IN_DTLP         - Data de Ap de Lucros e Perdas
                           @IN_STATUS       - Status
                           @IN_SLCOMP       - Sld Composto
                           @IN_DEBITO       - Movimento a debito
                           @IN_CREDIT       - Movimento a credito 
                           @IN_ANTDEB       - sald anterior a debito
                           @IN_ANTCRD       - sald anterior a credito 
                           @IN_ATUDEB       - sald atual a debito
                           @IN_ATUCRD       - sald atual a credito 
                           @IN_RECNO        - Recno
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     02/01/2004
-------------------------------------------------------------------------------------- */

   Declare @nDEBITO    Float
   Declare @nCREDIT    Float
   Declare @nATUDEB    Float
   Declare @nATUCRD    Float
   Declare @nANTDEB    Float
   Declare @nANTCRD    Float
   
begin
   
   select @nDEBITO  =  Round(@IN_DEBITO, 2)
   select @nCREDIT  =  Round(@IN_CREDIT, 2)
   select @nATUDEB  =  Round(@IN_ATUDEB, 2)
   select @nATUCRD  =  Round(@IN_ATUCRD, 2)
   select @nANTDEB  =  Round(@IN_ANTDEB, 2)
   select @nANTCRD  =  Round(@IN_ANTCRD, 2)
   
   Update CTY###
      Set CTY_DATA   = @IN_DATA,   CTY_LP     = @IN_LP,     CTY_DTLP   = @IN_DTLP,
          CTY_STATUS = @IN_STATUS, CTY_SLCOMP = @IN_SLCOMP, CTY_DEBITO = @nDEBITO, CTY_CREDIT = @nCREDIT,
          CTY_ANTDEB = @nANTDEB,   CTY_ANTCRD = @nANTCRD,   CTY_ATUDEB = @nATUDEB, CTY_ATUCRD = @nATUCRD
    Where R_E_C_N_O_ = @IN_RECNO
   
end
