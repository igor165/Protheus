#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TMSRF50.CH"
                                              
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMSRF50   ³ Autor ³ Marcelo CorreaCoutinho³ Data ³20/06/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Analise de Rentabilidade por Cliente                       ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSRF50()
Local oReport 
Local aArea   := GetArea()

oReport := ReportDef()
oReport:PrintDialog()

RestArea(aArea)
     
Return      

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
                        
Static Function ReportDef()
Local oReport    
Local oItens
Local cAliasQry := GetNextAlias()
Local cTexto    := ""                  
Local cDatIni   := ""                  
Local cDatFim   := ""                  

Local oCelPeso
Local oCelPesoM2
Local oCelVolume
Local oCelValMer
Local oCelCustos
Local oCelReceit
Local oCelRentab

Pergunte( "TMSRF50", .T. )

cDatIni := Posicione( 'DFJ', 1, xFilial( 'DFJ' ) + mv_par01, 'DFJ_DATINI' )
cDatFim := Posicione( 'DFJ', 1, xFilial( 'DFJ' ) + mv_par02, 'DFJ_DATFIM' )

cTexto  := STR0001 + Dtoc( cDatIni ) + " até " + Dtoc( cDatFim )

oReport := TReport():New( "TMSRF50", cTexto, "", { |oReport| ReportPrint( oReport, cAliasQry ) }, cTexto )
oReport:SetTotalInLine(.F.)
oReport:nFontBody   := 08
oReport:nLineHeight := 40 
oReport:SetColSpace(1) 
                
//LINHA DE DETALHE
oItens := TRSection():New( oReport, "Itens", {},,, )
oItens:SetTotalInLine(.F.)
oItens:SetLinesBefore(1)    
oItens:SetCharSeparator("") 
oItens:SetColSpace(1)
       
TRCell():New( oItens, "DT6_CLIDEV",,        ,                    ,   , /*lPixel*/, { || (cAliasQry)->DT6_CLIDEV } )
TRCell():New( oItens, "DT6_LOJDEV",, 'Loja' ,                    ,   , /*lPixel*/, { || (cAliasQry)->DT6_LOJDEV } )
TRCell():New( oItens, "A1_NOME"   ,,        ,                    , 20, /*lPixel*/, { || (cAliasQry)->A1_NOME    } )
TRCell():New( oItens, "DT6_PESO"  ,,        ,                    ,   , /*lPixel*/, { || (cAliasQry)->DT6_PESO   } )
TRCell():New( oItens, "DT6_PESOM3",,        ,                    ,   , /*lPixel*/, { || (cAliasQry)->DT6_PESOM3 } )
TRCell():New( oItens, "DT6_VOLORI",,        ,                    ,   , /*lPixel*/, { || (cAliasQry)->DT6_VOLORI } )
TRCell():New( oItens, "DT6_VALMER",,        ,                    ,   , /*lPixel*/, { || (cAliasQry)->DT6_VALMER } )
TRCell():New( oItens, "QRY_CUSTOS",, STR0002, "@E 999,999,999.99", 14, /*lPixel*/, { || (cAliasQry)->QRY_CUSTOS } )
TRCell():New( oItens, "QRY_RECEIT",, STR0003, "@E 999,999,999.99", 14, /*lPixel*/, { || (cAliasQry)->QRY_RECEIT } )
TRCell():New( oItens, "QRY_RENTAB",, STR0004, "@E 9,999.9999"    , 10, /*lPixel*/, { || (cAliasQry)->QRY_RENTAB } )

oItens:Cell( "DT6_PESO"   ):SetHeaderAlign( "RIGHT" )
oItens:Cell( "DT6_PESOM3" ):SetHeaderAlign( "RIGHT" )
oItens:Cell( "DT6_VOLORI" ):SetHeaderAlign( "RIGHT" )
oItens:Cell( "DT6_VALMER" ):SetHeaderAlign( "RIGHT" )
oItens:Cell( "QRY_CUSTOS" ):SetHeaderAlign( "RIGHT" )
oItens:Cell( "QRY_RECEIT" ):SetHeaderAlign( "RIGHT" )
oItens:Cell( "QRY_RENTAB" ):SetHeaderAlign( "RIGHT" )
     
DEFINE FUNCTION oCelPeso   FROM oItens:Cell( "DT6_PESO"   ) OF oItens FUNCTION SUM     TITLE "" NO END SECTION
DEFINE FUNCTION oCelPesoM2 FROM oItens:Cell( "DT6_PESOM3" ) OF oItens FUNCTION SUM     TITLE "" NO END SECTION
DEFINE FUNCTION oCelVolume FROM oItens:Cell( "DT6_VOLORI" ) OF oItens FUNCTION SUM     TITLE "" NO END SECTION
DEFINE FUNCTION oCelValMer FROM oItens:Cell( "DT6_VALMER" ) OF oItens FUNCTION SUM     TITLE "" NO END SECTION
DEFINE FUNCTION oCelCustos FROM oItens:Cell( "QRY_CUSTOS" ) OF oItens FUNCTION SUM     TITLE "" NO END SECTION
DEFINE FUNCTION oCelReceit FROM oItens:Cell( "QRY_RECEIT" ) OF oItens FUNCTION SUM     TITLE "" NO END SECTION
DEFINE FUNCTION oCelRentab FROM oItens:Cell( "QRY_RENTAB" ) OF oItens FUNCTION ONPRINT TITLE "" FORMULA { || ( 100 - ( ( oCelCustos:GetValue() * 100 ) / oCelReceit:GetValue() ) ) } NO END SECTION

Return(oReport)
                
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor                         ³ Data ³18.06.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
                          
Static Function ReportPrint( oReport, cAliasQry )

Local cCusto := '%DFN_CUSTO' + Str( MV_PAR11, 1 ) + '%'
                 
oReport:Section(1):BeginQuery()

  BeginSql Alias cAliasQry
             
      SELECT 
				DT6_CLIDEV,
				DT6_LOJDEV,
				A1_NOME,
				SUM ( DT6_VOLORI ) AS DT6_VOLORI,
				SUM( DT6_PESO )     AS DT6_PESO,
				SUM( DT6_PESOM3 )   AS DT6_PESOM3,
				SUM( DT6_VALMER )   AS DT6_VALMER,
				SUM( DT6_VALTOT )   AS QRY_RECEIT,
				SUM( %exp:cCusto% ) AS QRY_CUSTOS,
				( 100 - ( ( SUM( %exp:cCusto% ) * 100 ) / SUM( DT6_VALTOT ) ) ) AS QRY_RENTAB

        FROM
				%table:DTQ% AS DTQ,
				%table:DUD% AS DUD,
				%table:DT6% AS DT6,
				%table:DFN% AS DFN,
				%table:SA1% AS SA1

       WHERE DTQ.%NotDel%
         AND DTQ.DTQ_FILIAL = %xFilial:DTQ%
         AND DTQ.DTQ_SERTMS BETWEEN %exp:mv_par07% AND %exp:mv_par08%
         AND DTQ.DTQ_TIPTRA BETWEEN %exp:mv_par09% AND %exp:mv_par10%
    	   AND DUD.%NotDel%
         AND DUD.DUD_FILIAL = %xFilial:DUD%
   	   AND DUD.DUD_FILORI = DTQ.DTQ_FILORI
  	      AND DUD.DUD_VIAGEM = DTQ.DTQ_VIAGEM
   	   AND DT6.%NotDel%
         AND DT6.DT6_FILIAL = %xFilial:DT6%
     	   AND DT6.DT6_FILDOC = DUD.DUD_FILDOC
	      AND DT6.DT6_DOC    = DUD.DUD_DOC
	      AND DT6.DT6_SERIE  = DUD.DUD_SERIE
	      AND DT6.DT6_CLIDEV BETWEEN %exp:mv_par03% AND %exp:mv_par05%
	      AND DT6.DT6_LOJDEV BETWEEN %exp:mv_par04% AND %exp:mv_par06%
		   AND DFN.%NotDel%
         AND DFN.DFN_FILIAL = %xFilial:DFN%
         AND DFN.DFN_IDCTMS BETWEEN %exp:mv_par01% AND %exp:mv_par02%
   	   AND DFN.DFN_FILDOC = DUD.DUD_FILDOC
	      AND DFN.DFN_DOC    = DUD.DUD_DOC
	      AND DFN.DFN_SERIE  = DUD.DUD_SERIE
	      AND DFN.DFN_SERTMS = DTQ.DTQ_SERTMS
		   AND SA1.%NotDel%
   	   AND SA1.A1_COD     = DT6.DT6_CLIDEV
   	   AND SA1.A1_LOJA    = DT6.DT6_LOJDEV

       GROUP BY DT6_CLIDEV, DT6_LOJDEV, A1_NOME

       ORDER BY QRY_RENTAB DESC
             
EndSql
         
oReport:Section(1):EndQuery()

oReport:Section(1):SetParentQuery()

oReport:SetMeter((cAliasQry)->(LastRec()))
oReport:Section(1):Print()
   
Return Nil