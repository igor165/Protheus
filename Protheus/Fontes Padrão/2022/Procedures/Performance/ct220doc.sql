CREATE PROCEDURE CT220DOC_##
 (
   @IN_FILIAL      Char( 'CT2_FILIAL' ),
   @IN_CT2_DATA    Char( 08 ),
   @IN_CT2_LINHA   Char( 'CT2_LINHA' ),
   @IN_CT2_TPSALD  Char( 'CT2_TPSALD' ),
   @IN_CT2_EMPORI  Char( 'CT2_EMPORI' ),
   @IN_CT2_FILORI  Char( 'CT2_FILORI' ),
   @IN_CT2_MOEDLC  Char( 'CT2_MOEDLC' ),
   @IN_CT2_LOTE    Char( 'CT2_LOTE' ),
   @IN_CT2_SBLOTE  Char( 'CT2_SBLOTE' ),
   @IN_CT2_DOC     Char( 'CT2_DOC' ),
   @OUT_CT2_LOTE   Char( 'CT2_LOTE' ) OutPut,
   @OUT_CT2_SBLOTE Char( 'CT2_SBLOTE' ) OutPut,
   @OUT_CT2_DOC    Char( 'CT2_DOC' ) OutPut
  )
as
/* ---------------------------------------------------------------------------------------------------------------------
    Programa    - <s> CTB220DOC Ponto de Entrada </s>
    Versão      - <v> Protheus 9.12 </v>
    Assinatura  - <a> 001 </a>
    Descricao   - <d> Ponto de entrada para gerar linhas únicas no CT2 </d>
    Entrada     -  <ri> @IN_FILIAL      - Filial da Empresa cosolidante
                        @IN_CT2_DATA    - Data do lancto
                        @IN_CT2_LINHA   - Linha do Lancto
                        @IN_CT2_TPSALD  - Tipo de Saldo
                        @IN_CT2_EMPORI  - Empresa origem do lancto
                        @IN_CT2_FILORI  - Filial origem do lancto
                        @IN_CT2_MOEDLC  - Moeda do lancto
                        @IN_CT2_LOTE    - Lote do Lancto
                        @IN_CT2_SBLOTE  - Sublote do Lancto
                        @IN_CT2_DOC     - Documento do Lancto  </ri>
    Saida       - <ro>  @OUT_CT2_LOTE   - Lote de Saida
                        @OUT_CT2_SBLOTE - SubLote de Saida
                        @OUT_CT2_DOC    - Documento de Saida </ro>
    Data        :  <dt> 21/10/2004 </dt>
--------------------------------------------------------------------------------------------------------------------- */
Declare @cCT2_LOTE     Char( 'CT2_LOTE' )
Declare @cCT2_SBLOTE   Char( 'CT2_SBLOTE' )
Declare @cCT2_DOC      Char( 'CT2_DOC' )

begin
 Select @cCT2_LOTE   = @IN_CT2_LOTE
 Select @cCT2_SBLOTE = @IN_CT2_SBLOTE
 Select @cCT2_DOC    = @IN_CT2_DOC   

 Select @OUT_CT2_LOTE   = @cCT2_LOTE
 Select @OUT_CT2_SBLOTE = @cCT2_SBLOTE
 Select @OUT_CT2_DOC    = @cCT2_DOC
end
