#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TMSRF10.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMSRF10   ³ Autor ³ Marcelo C. Coutinho   ³ Data ³18/06/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Resumo de Custos de Veiculos por Filial                    ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSRF10()
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
Local cDesc1    := ""
Local cDesc2    := ""
Local cDesc3    := ""

Local oDesp1
Local oDesp2
Local oDesp3
Local oCelKm
Local oCelPeso
Local oCelValMer
Local oCelVolume
Local oCelOutras
Local oCelTotal
Local oCelValKm

Pergunte( "TMSRF10", .T. )

cDesc1  := AllTrim( mv_par04 )
cDesc2  := AllTrim( mv_par06 )
cDesc3  := AllTrim( mv_par08 )

cDatIni := Posicione( 'DFJ', 1, xFilial( 'DFJ' ) + mv_par01, 'DFJ_DATINI' )
cDatFim := Posicione( 'DFJ', 1, xFilial( 'DFJ' ) + mv_par02, 'DFJ_DATFIM' )

cTexto  := STR0001 + ": " + Dtoc( cDatIni ) + " até " + Dtoc( cDatFim )

oReport := TReport():New( "TMSRF10", cTexto, "", { |oReport| ReportPrint( oReport, cAliasQry ) }, cTexto )
oReport:SetTotalInLine(.F.)
oReport:SetLandscape()
oReport:SetColSpace(1) 
oReport:nFontBody   := 08
oReport:nLineHeight := 40 
oReport:lDisableOrientation := .T. 

// QUEBRA VARIAVEL
oFilial := TRSection():New( oReport, STR0002, { cAliasQry }, { "Filial" }, /*Campos do SX3*/, /*Campos do SIX*/ )
oFilial:SetTotalInLine(.F.)
oFilial:SetPageBreak(.F.)
oFilial:SetCharSeparator("")
oFilial:SetLineStyle()
oFilial:SetCols(1)
oFilial:SetLinesBefore(1)

oFilial:OnPrintLine( { || VisFilBas( oReport, cAliasQry ) } ) 

//LINHA DE DETALHE
oItens := TRSection():New( oFilial, "Itens", { cAliasQry },,, )
oItens:SetTotalInLine(.F.)
oItens:SetLinesBefore(1)
oItens:SetCharSeparator("")
oItens:SetColSpace(1)         

TRCell():New( oItens, "DA3_TIPVEI",,,, 10, /*lPixel*/, { || (cAliasQry)->DUT_DESCRI } )
TRCell():New( oItens, "DA3_DESC"  ,,,, 10, /*lPixel*/, { || (cAliasQry)->DA3_DESC   } )
TRCell():New( oItens, "DA3_PLACA" ,,,, 10, /*lPixel*/, { || (cAliasQry)->DA3_PLACA  } )
TRCell():New( oItens, "DFK_KM"    ,,,,   , /*lPixel*/, { || (cAliasQry)->DFK_KM     } )
TRCell():New( oItens, "DFK_PESO"  ,,,,   , /*lPixel*/, { || (cAliasQry)->DFK_PESO   } )
TRCell():New( oItens, "DFK_VALMER",,,,   , /*lPixel*/, { || (cAliasQry)->DFK_VALMER } )
TRCell():New( oItens, "DFK_QTDVOL",,,,   , /*lPixel*/, { || (cAliasQry)->DFK_QTDVOL } )

If !Empty( cDesc1 )
	TRCell():New( oItens, cDesc1   ,, AllTrim( cDesc1 ), "@E 999,999,999.99", 14, /*lPixel*/, { || Iif( VAlType( (cAliasQry)->QRY_VALOR1 ) <> 'N', 0, (cAliasQry)->QRY_VALOR1 ) } )
EndIf

If !Empty( cDesc2 )
	TRCell():New( oItens, cDesc2   ,, AllTrim( cDesc2 ), "@E 999,999,999.99", 14, /*lPixel*/, { || Iif( VAlType( (cAliasQry)->QRY_VALOR2 ) <> 'N', 0, (cAliasQry)->QRY_VALOR2 ) } )
EndIf

If !Empty( cDesc3 )
	TRCell():New( oItens, cDesc3   ,, AllTrim( cDesc3 ), "@E 999,999,999.99", 14, /*lPixel*/, { || Iif( VAlType( (cAliasQry)->QRY_VALOR3 ) <> 'N', 0, (cAliasQry)->QRY_VALOR3 ) } )
EndIf

TRCell():New( oItens, "OUTRASDS"  ,, STR0003          , "@E 999,999,999.99", 14, /*lPixel*/, { ||   Iif( VAlType( (cAliasQry)->QRY_OUTRAS ) <> 'N', 0, (cAliasQry)->QRY_OUTRAS ) } )
TRCell():New( oItens, "CUSTOTOTAL",, STR0004          , "@E 999,999,999.99", 14, /*lPixel*/, { || ( Iif( VAlType( (cAliasQry)->QRY_VALOR1 ) <> 'N', 0, (cAliasQry)->QRY_VALOR1 ) + ;
                                                                                                    Iif( VAlType( (cAliasQry)->QRY_VALOR2 ) <> 'N', 0, (cAliasQry)->QRY_VALOR2 ) + ;
                                                                                                    Iif( VAlType( (cAliasQry)->QRY_VALOR3 ) <> 'N', 0, (cAliasQry)->QRY_VALOR3 ) + ;
                                                                                                    Iif( VAlType( (cAliasQry)->QRY_OUTRAS ) <> 'N', 0, (cAliasQry)->QRY_OUTRAS ) ) } )

TRCell():New( oItens, "CUSTOKM"   ,, STR0005          , "@E 9,999.9999"    , 10, /*lPixel*/, { || ( Iif( VAlType( (cAliasQry)->QRY_VALOR1 ) <> 'N', 0, (cAliasQry)->QRY_VALOR1 )   + ;
                                                                                                    Iif( VAlType( (cAliasQry)->QRY_VALOR2 ) <> 'N', 0, (cAliasQry)->QRY_VALOR2 )   + ;
                                                                                                    Iif( VAlType( (cAliasQry)->QRY_VALOR3 ) <> 'N', 0, (cAliasQry)->QRY_VALOR3 )   + ;
                                                                                                    Iif( VAlType( (cAliasQry)->QRY_OUTRAS ) <> 'N', 0, (cAliasQry)->QRY_OUTRAS ) ) / ;
                                                                                                                  (cAliasQry)->DFK_KM                                              } )

oItens:Cell( "DFK_PESO"   ):SetHeaderAlign( "RIGHT" )
oItens:Cell( "DFK_VALMER" ):SetHeaderAlign( "RIGHT" )
oItens:Cell( "DFK_QTDVOL" ):SetHeaderAlign( "RIGHT" )
oItens:Cell( "OUTRASDS"   ):SetHeaderAlign( "RIGHT" )
oItens:Cell( "CUSTOTOTAL" ):SetHeaderAlign( "RIGHT" )
oItens:Cell( "CUSTOKM"    ):SetHeaderAlign( "RIGHT" )

DEFINE BREAK oQuebraFil OF oItens ;
       WHEN  { || Quebra( cAliasQry ) } ;
       TITLE { || STR0006 }

If !Empty( cDesc1 )

	oItens:Cell( cDesc1    ):SetHeaderAlign( "RIGHT" )
  
   DEFINE FUNCTION oDesp1  FROM oItens:Cell( cDesc1 )       OF oItens FUNCTION SUM     BREAK oQuebraFil TITLE "" NO END SECTION

EndIf

If !Empty( cDesc2 )

	oItens:Cell( cDesc2    ):SetHeaderAlign( "RIGHT" )

   DEFINE FUNCTION oDesp2  FROM oItens:Cell( cDesc2 )       OF oItens FUNCTION SUM     BREAK oQuebraFil TITLE "" NO END SECTION

EndIf

If !Empty( cDesc3 )

	oItens:Cell( cDesc3    ):SetHeaderAlign( "RIGHT" )

   DEFINE FUNCTION oDesp3  FROM oItens:Cell( cDesc3 )       OF oItens FUNCTION SUM     BREAK oQuebraFil TITLE "" NO END SECTION

EndIf

DEFINE FUNCTION oCelKm     FROM oItens:Cell( "DFK_KM"     ) OF oItens FUNCTION SUM     BREAK oQuebraFil TITLE "" NO END SECTION
DEFINE FUNCTION oCelPeso   FROM oItens:Cell( "DFK_PESO"   ) OF oItens FUNCTION SUM     BREAK oQuebraFil TITLE "" NO END SECTION
DEFINE FUNCTION oCelValMer FROM oItens:Cell( "DFK_VALMER" ) OF oItens FUNCTION SUM     BREAK oQuebraFil TITLE "" NO END SECTION
DEFINE FUNCTION oCelVolume FROM oItens:Cell( "DFK_QTDVOL" ) OF oItens FUNCTION SUM     BREAK oQuebraFil TITLE "" NO END SECTION
DEFINE FUNCTION oCelOutras FROM oItens:Cell( "OUTRASDS"   ) OF oItens FUNCTION SUM     BREAK oQuebraFil TITLE "" NO END SECTION
DEFINE FUNCTION oCelTotal  FROM oItens:Cell( "CUSTOTOTAL" ) OF oItens FUNCTION SUM     BREAK oQuebraFil TITLE "" NO END SECTION
DEFINE FUNCTION oCelValKm  FROM oItens:Cell( "CUSTOKM"    ) OF oItens FUNCTION ONPRINT BREAK oQuebraFil TITLE "" FORMULA { || ( oCelTotal:GetLastValue() / oCelKm:GetLastValue() ) } NO END SECTION

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

Local cCusto1  := '%DFL1.DFL_CUSTO' + Str( MV_PAR09, 1 ) + '%'
Local cCusto2  := '%DFL2.DFL_CUSTO' + Str( MV_PAR09, 1 ) + '%'
Local cCusto3  := '%DFL3.DFL_CUSTO' + Str( MV_PAR09, 1 ) + '%'
Local cCusto4  := '%DFL4.DFL_CUSTO' + Str( MV_PAR09, 1 ) + '%'

Local cCodDes  := ''
Local cCodDes1 := AllTrim(mv_par03)	// 1§ Despesa/Custo
Local cCodDes2 := AllTrim(mv_par05)	// 2§ Despesa/Custo
Local cCodDes3 := AllTrim(mv_par07)	// 3§ Despesa/Custo
Local nControl := 0

If !Empty(cCodDes1)
	cCodDes += AllTrim(cCodDes1) + "',"
	nControl := 1
EndIf
If !Empty(cCodDes1) .AND. !Empty(cCodDes2)  
	cCodDes += "'" + AllTrim(cCodDes2) + "',"
	nControl := nControl + 1
ElseIf !Empty(cCodDes2)
	cCodDes += AllTrim(cCodDes2) + "',"
	nControl := nControl + 1
EndIf
If nControl > 0 .AND. !Empty(cCodDes3)
	cCodDes += "'" + AllTrim(cCodDes3) + "'"
	nControl := nControl + 1
ElseIf !Empty(cCodDes3)
	cCodDes += AllTrim(cCodDes3) + "'"
EndIf
If !Empty(cCodDes)
	cCodDes := SubStr(cCodDes,1, Len(cCodDes)-1)
	If nControl < 3 .AND. Empty(cCodDes3)
		cCodDes := SubStr(cCodDes,1, Len(cCodDes)-1)
	EndIf	 
EndIf

oReport:Section(1):BeginQuery()

  BeginSql Alias cAliasQry

      SELECT
      			DFL.DFL_FILIAL,
      			DA3.DA3_FILBAS,
      			DFL.DFL_IDCTMS,
      			DFL.DFL_CODVEI,
      			DA3.DA3_DESC,
      			DA3.DA3_PLACA,
      			DFK.DFK_KM,
      			DFK.DFK_PESO,
      			DFK.DFK_QTDVOL,
      			DFK.DFK_VALMER,
      			DA3.DA3_TIPVEI,
      			DUT.DUT_DESCRI,
      			DFJ.DFJ_DATINI,

            ( SELECT SUM( %exp:cCusto1% )
                FROM %table:DFL% AS DFL1
               WHERE DFL1.%NotDel%
                 AND DFL1.DFL_FILIAL = %xFilial:DFL%
                 AND DFL1.DFL_CODVEI = DFL.DFL_CODVEI
                 AND DFL1.DFL_IDCTMS = DFL.DFL_IDCTMS
                 AND DFL1.DFL_CODDES = ( %exp:cCodDes1% ) ) AS QRY_VALOR1,

            ( SELECT SUM( %exp:cCusto2% ) 
                FROM %table:DFL% AS DFL2
               WHERE DFL2.%NotDel%
                 AND DFL2.DFL_FILIAL = %xFilial:DFL%
                 AND DFL2.DFL_CODVEI = DFL.DFL_CODVEI
                 AND DFL2.DFL_IDCTMS = DFL.DFL_IDCTMS
                 AND DFL2.DFL_CODDES = ( %exp:cCodDes2% ) ) AS QRY_VALOR2,

            ( SELECT SUM( %exp:cCusto3% )
                FROM %table:DFL% AS DFL3
               WHERE DFL3.%NotDel%
                 AND DFL3.DFL_FILIAL = %xFilial:DFL%
                 AND DFL3.DFL_CODVEI = DFL.DFL_CODVEI
                 AND DFL3.DFL_IDCTMS = DFL.DFL_IDCTMS
                 AND DFL3.DFL_CODDES = ( %exp:cCodDes3% ) ) AS QRY_VALOR3,

            ( SELECT SUM( %exp:cCusto4% ) 
                FROM %table:DFL% AS DFL4
               WHERE DFL4.%NotDel%
                 AND DFL4.DFL_FILIAL = %xFilial:DFL%
                 AND DFL4.DFL_CODVEI = DFL.DFL_CODVEI
                 AND DFL4.DFL_IDCTMS = DFL.DFL_IDCTMS
                 AND DFL4.DFL_CODDES NOT IN ( %exp:cCodDes% ) ) AS QRY_OUTRAS

        FROM %table:DFL% AS DFL

	     JOIN %table:DFK% AS DFK  ON DFK.DFK_FILIAL  = %xFilial:DTQ% AND DFK.DFK_IDCTMS = DFL.DFL_IDCTMS AND DFK.DFK_CODVEI = DFL.DFL_CODVEI AND DFK.%NotDel%
		  JOIN %table:DA3% AS DA3  ON DA3.DA3_FILIAL  = %xFilial:DA3% AND DA3.DA3_COD    = DFL.DFL_CODVEI AND DA3.DA3_TIPVEI BETWEEN %exp:mv_par10% AND %exp:mv_par11% AND DA3.%NotDel%
		  JOIN %table:DUT% AS DUT  ON DUT.DUT_FILIAL  = %xFilial:DUT% AND DUT.DUT_TIPVEI = DA3.DA3_TIPVEI AND DUT.%NotDel%
		  JOIN %table:DFJ% AS DFJ  ON DFJ.DFJ_FILIAL  = %xFilial:DFJ% AND DFJ.DFJ_IDCTMS = DFL.DFL_IDCTMS AND DFJ.%NotDel%
                                                                                
       WHERE DFL.%NotDel%
         AND DFL.DFL_FILIAL = %xFilial:DFL%
         AND DFL.DFL_IDCTMS BETWEEN %exp:mv_par01% AND %exp:mv_par02%
         AND DFL.DFL_CODDES IN ( %exp:cCodDes% )

       GROUP BY DFL.DFL_FILIAL,
			       DA3.DA3_FILBAS,
			       DFL.DFL_IDCTMS,
			       DFL.DFL_CODVEI,
			       DA3.DA3_DESC,
			       DA3.DA3_PLACA,
   			    DFK.DFK_KM,
			       DFK.DFK_PESO,
			       DFK.DFK_QTDVOL,
			       DFK.DFK_VALMER,
			       DA3.DA3_TIPVEI,
			       DUT.DUT_DESCRI,
			       DFJ.DFJ_DATINI

		 ORDER BY DFL.DFL_FILIAL, DA3.DA3_TIPVEI, DFL.DFL_CODVEI

EndSql
         
oReport:Section(1):EndQuery()

oReport:Section(1):SetParentQuery()

oReport:SetMeter((cAliasQry)->(LastRec()))
oReport:Section(1):Print()
   
Return Nil

//======================================================
//Cabecalho
//======================================================

Static Function VisFilBas(oReport, cAliasQry)

Local cFilBas := ( cAliasQry )->DA3_FILBAS

oReport:SkipLine()

oReport:PrintText( STR0007 + ":  " + Posicione( "DUY", 5, xFilial( "DUY" ) + cFilBas + "2", "DUY_DESCRI" ) )

oReport:SkipLine()

Return .F. 

//======================================================
//Controle da Quebra
//======================================================
Static Function Quebra( cAliasQry )

Return ( cAliasQry )->DA3_FILBAS      
