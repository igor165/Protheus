#include "RwMake.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "FINR085K.ch"

#define PIX_DIF_COLUNA_VALORES			275		// Pixel inicial para impressao dos tracos das colunas dinamicas
#define PIX_INICIAL_VALORES				470		// Pixel para impressao do traco vertical
#define PIX_EQUIVALENTE				  	340		// Pixel inicial para impressao das colunas dinamicas

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออ'อออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINR085K   บ Autor ณ Totvs              บ Data ณ  06/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณCertificado de Reten็ใo do Imposto ITBIS - Rep Dom  		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFINR085K                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FINR085K()

Local cPerg		:= "FI085K"

PRIVATE oCRReport

/*ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ mv_par01 - Data inicial? - Data inicial dos Certificados     	ณ
ณ mv_par02 - Data Final? 	- Data final dos Certificados         	ณ
ณ mv_par03 - Fornecedor? 	- Fornec inicial dos Certificados		ณ
ณ mv_par04 - Fornecedor? 	- Fornec final dos Certificados      	ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ*/
If TRepInUse()
	Pergunte(cPerg,.F.)
	oCRReport := FINRelat(cPerg)
	oCRReport:SetParam(cPerg)
	oCRReport:PrintDialog()
EndIf

Return

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFINRelat  ณ Autor ณ Totvs                 ณ Data | 06/05/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณCria็ใo do objeto TReport para a impressใo do relatorio.    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณFINRelat( cPerg )           				                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณExpC1 = Perguntas dos parametros                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FINRelat( cPerg )

Local clNomProg		:= FunName()
Local clTitulo 		:= STR0001 //"Certificado de Reten็ใo de Impostos"
Local clDesc   		:= STR0001 //"Certificado de Reten็ใo de Impostos"
Local oCRReport

oCRReport:=TReport():New(clNomProg,clTitulo,cPerg,{|oCRReport| FINProc(oCRReport)},clDesc)
oCRReport:lHeaderVisible 			:= .F. 	// Nใo imprime cabe็alho do protheus
oCRReport:lFooterVisible 			:= .F.		// Nใo imprime rodap้ do protheus
oCRReport:lParamPage		  		:= .F.		// Nใo imprime pagina de parametros

oCRReport:DisableOrientation()           // Nใo permite mudar o formato de impressใo para Vertical, somente landscape
oCRReport:SetEdit(.F.)                   // Nใo permite personilizar o relat๓rio, desabilitando o botใo <Personalizar>

//+----------------+
//|Define as fontes|
//+----------------+

Return oCRReport

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFINProc   ณ Autor ณ Totvs                 ณ Data | 06/05/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณImpressใo do relatorio.								      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ FINProc( ExpC1 )         				                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณExpC1 = Objeto tReport                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FINProc( oCRReport )


Local cQuery		:= ""
Local aEquivale 	:= { 0, 0, 0, 0, 0}
Local nTotalCols	:= Len( aEquivale )
Local aTotais		:= Array( nTotalCols )
Local nRowStart		:= 0
Local nNumVias      := mv_par05
Local cNumCert 		:= ""
Local cEndereco     := ""
Local cNome 		:= ""
Local cEstado 		:= ""
Local cFilial 		:= ""
Local cCidade       := ""
Local cDtEmissao    := ""
Local cRnc          := ""
Local cNroCert	    := ""
Local cNumeroCert   := ""
Local cNotaFiscal	:= ""
Local nTotalRetido  := 0.00
Local nCount        := 0
Local lFIR085CP		:= ExistBlock("FIR085CP")
Local nPagIni  		:= 1
Local aSFEItens    := {}
Local nC           := 0

// Inicia o array totalizador com zero
aFill( aTotais, 0 )

cQuery := ""
cQuery += "SELECT "
cQuery += "FE_NROCERT, "
cQuery += "FE_EMISSAO, "
cQuery += "FE_FORNECE, "
cQuery += "FE_LOJA, "
cQuery += "FE_NFISCAL, "
cQuery += "FE_SERIE, "
cQuery += "FE_TPTIMP, "
cQuery += "FE_TIPO, "
cQuery += "FE_ORDPAGO, "
cQuery += "FE_CONCEPT, "
cQuery += "FE_VALBASE, "
cQuery += "FE_ALIQ, "
cQuery += "FE_PORCRET, "
cQuery += "FE_VALIMP, "
cQuery += "A2_NOME, "
cQuery += "A2_CGC, "
cQuery += "A2_END, "
cQuery += "A2_MUN, "
cQuery += "A2_EST "
cQuery += "FROM "
cQuery += RetSqlName("SFE")+" SFE, "
cQuery += RetSqlName("SA2")+" SA2  "
cQuery += "WHERE "
cQuery += "SFE.FE_FILIAL = '" + xFilial("SFE") + "' "
cQuery += "AND SA2.A2_FILIAL = '" + xFilial("SA2") + "' "
cQuery += "AND SFE.FE_FORNECE BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
cQuery += "AND SFE.FE_EMISSAO BETWEEN '" + DTOS(mv_par03) + "' AND '" + DTOS(mv_par04) + "' "
cQuery += "AND SFE.FE_TPTIMP	IN	('IT') "
cQuery += "AND SFE.FE_FORNECE = SA2.A2_COD "
cQuery += "AND SFE.FE_LOJA = SA2.A2_LOJA "
cQuery += "AND SFE.D_E_L_E_T_ <> '*' "
cQuery += "AND SA2.D_E_L_E_T_ <> '*' "
cQuery += "AND SFE.FE_FORNECE <> '' "
cQuery += " ORDER BY FE_FORNECE, FE_EMISSAO "

cQuery := ChangeQuery( cQuery  )
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "PER",.T.,.T.)

TCSetField( "PER", "FE_EMISSAO",  "D", 08, 0 )
TCSetField( "PER", "FE_VALBASE",  "N", TamSX3( "FE_VALBASE" )[1], TamSX3( "FE_VALBASE" )[2] )
TCSetField( "PER", "FE_ALIQ"   ,  "N", TamSX3( "FE_ALIQ" )[1], TamSX3( "FE_ALIQ" )[2] )
TCSetField( "PER", "FE_VALIMP" ,  "N", TamSX3( "FE_VALIMP" )[1], TamSX3( "FE_VALIMP" )[2] )

If lFIR085CP
	ExecBlock("FIR085CP",.F.,.F.)
EndIf

If ! lFIR085CP

	DbSelectArea( "PER" )
	PER->( DbGoTop() )
	While PER->(!Eof())
       AADD(aSFEItens,{PER->FE_NROCERT,PER->FE_EMISSAO,PER->FE_VALBASE,PER->FE_TPTIMP,PER->FE_CONCEPT,;
                       PER->FE_ALIQ,PER->FE_VALIMP,PER->FE_PORCRET})
  		PER->(dbSkip())
	End

	dbSelectArea( "PER" )
	PER->( DbGoTop() )

	// Determina o pixel vertical inicial
	nRowStart		:= oCRReport:Row()

	oCRReport:SetMeter( RecCount() )

	While PER->(!Eof())

		If oCRReport:Cancel()
			Exit
		EndIf

		For nCount := 1 To nNumVias

            nPagIni  := 1
			cNumCert := ""
			cFilial		:= AllTrim(SM0->M0_FILIAL)
		  	cNome       := AllTrim(SM0->M0_NOME)
			cEndereco   := AllTrim(SM0->M0_ENDCOB)
			cCidade     := AllTrim(SM0->M0_CIDCOB)
			cEstado		:= AllTrim(SM0->M0_ESTCOB)
			cDtEmissao  := FINR085D01(PER->FE_EMISSAO)
			cRnc        := STR0002 +Transform(SM0->M0_CGC,"@R 9999999999999")  //"RNC"
			cNroCert	:= Transform(PER->FE_NROCERT,"@R !99999999999999")
			cNotaFiscal	:= PER->FE_NFISCAL
//			cAutoriza   := "AUTORIZACAO: " +Transform(AllTrim(PER->EK_NUMAUT),"9999999999")

			oCRReport:SetPageNumber(nPagIni)
			oCRReport:PrintText(cNome										,0010,0080)
			oCRReport:PrintText(cCidade+" "+cEstado					   		,0050,0080)
			oCRReport:PrintText(STR0003 		                  			,0100,0080)  //"MATRIZ "
			oCRReport:PrintText(cFilial+" "+Subs(cEndereco,1,50)+" "+cEstado,0100,0150)
			//Informa็๕es apresentadas na cabe็alho, no Box
			oCRReport:PrintText(cRnc						                ,0010,1600)

			oCRReport:PrintText(STR0004										,0050,1600)  //"COMPROBANTE DE RETENCION"
			oCRReport:PrintText(STR0005 + cNroCert							,0100,1600)  //"No. "

			dbSelectArea("SA2")
			SA2->(dbSetOrder(1))
			SA2->(dbGoTop())
			SA2->(dbSeek(xFilial("SA2")+AvKey(PER->FE_FORNECE,"A2_COD")+AvKey(PER->FE_LOJA,"A2_LOJA")))

	  		oCRReport:Box(0550,0080,0300,2350)
			oCRReport:PrintText(STR0006 + AllTrim(SA2->A2_NOME)       		,0360,0100)  //"Sr.(es): "
			oCRReport:PrintText(STR0007 + Transform(SA2->A2_CGC,"@R 9999999999999"),0420,0100)  //"No. R.U.C.: "
			oCRReport:PrintText(STR0008 + AllTrim(SA2->A2_END) + " " + AllTrim(SA2->A2_MUN) + " " + AllTrim(SA2->A2_EST),0480,0100)  //"Direcci๓n: "

			oCRReport:PrintText(STR0009 + cDtEmissao,0360,1600)  //"Fecha de Emisi๓n: "
			oCRReport:PrintText(STR0010 + STR0011,0420,1600)  //"Tipo comprobante : " + "FACTURA"
			oCRReport:PrintText(STR0012 + PER->FE_NFISCAL,0480,1600)  //"No. comprobante : "

			oCRReport:Box(0650,0080,1820,2350)
			oCRReport:Line(0780,0080,0780,2350)//Linha Horizontal

			oCRReport:Line(0650,0350,1820,0350)//Linha Vertical 1
			oCRReport:Line(0650,0800,1820,0800)//Linha Vertical 2
			oCRReport:Line(0650,1150,1820,1150)//Linha Vertical 3
			oCRReport:Line(0650,1600,1820,1600)//Linha Vertical 4
			oCRReport:Line(0650,1950,1820,1950)//Linha Vertical 5

			oCRReport:PrintText(STR0013,0660,0090)	//"Ejercicio Fiscal"
			oCRReport:PrintText(STR0014,0660,0420)	//"Base Imponible"
			oCRReport:PrintText(STR0015,0660,0900)  //"Impuesto"
			oCRReport:PrintText("",0660,0850)
			oCRReport:PrintText(STR0016,0660,1250)  //"Cod.Impuesto"
			oCRReport:PrintText(STR0017,0660,1650)  //" % de Retenci๓n"
			oCRReport:PrintText(STR0018,0660,2080)  //"Vlr.Retenido"

			oCRReport:PrintText(STR0019,0700,0420)  //"para la Retenci๓n"

			nlLin := 850

	        cNumeroCert  := PER->FE_NROCERT
			nTotalRetido := 0.00

			For nC := 1 To Len(aSFEItens)
				If aSFEItens[nC][1] == cNumeroCert
					cExercicio := StrZero(Year(aSFEItens[nC][2]),4)
					oCRReport:PrintText(Transform(cExercicio,"9999")                            ,nlLin,0150)
					oCRReport:PrintText(Transform(aSFEItens[nC][3],"@E 999,999,999.99")			,nlLin,0400)
					oCRReport:PrintText(IIF(SubStr(aSFEItens[nC][4],1,3)=="IT ","ITBIS"," ")	,nlLin,0900)
					oCRReport:PrintText(aSFEItens[nC][5]         								,nlLin,1300)
					If aSFEItens[nC][8] > 0
				   		aSFEItens[nC][6] := aSFEItens[nC][6] * aSFEItens[nC][8] / 100
				 	EndIf
					oCRReport:PrintText(Transform(aSFEItens[nC][6],"@E %999.99")				,nlLin,1670)
					oCRReport:PrintText(Transform(aSFEItens[nC][7],"@E 999,999,999.99")			,nlLin,2000)
					nTotalRetido += aSFEItens[nC][7]
					nlLin += 40
				EndIf
			Next nC

 			oCRReport:Line(1740,1600,1740,2350)
			oCRReport:PrintText(STR0020														,1750,1620)  //"VALOR RETENIDO"
			oCRReport:PrintText(Transform(nTotalRetido,"@E 999,999,999.99")								,1750,2000)

    		oCRReport:PrintText(STR0021,2200,1620)  //"Original: Sujeto pasivo de retenido"
			oCRReport:PrintText(STR0022,2240,1620)  //"C๓pia: Agente de retenci๓n"

			oCRReport:Line(2050,0080,2050,0810)

			oCRReport:PrintText(STR0023,2070,0150)  //"FIRMA AGENTE DE RETENCION"
			oCRReport:PrintText(STR0024 + StrZero(Month(dDataBase),2) + "/" + StrZero(Year(dDataBase),4),2070,1680)  //"Vแlido para su emisi๓n hasta "

			oCRReport:EndPage()

   		Next nCount
   		oCRReport:IncMeter()
   		While PER->(!Eof()) .and. PER->FE_NROCERT == cNumeroCert
	  		PER->(dbSkip())
		End
	End
EndIf
PER->( DbCloseArea() )
Return oCRReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FINR085D01 บAutor  ณ Jose Lucas	    บ Data ณ   20/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retornar a data de Emissao no formato <cNomeMes><Dia>/<ano>บฑฑ
ฑฑบ          ณ Exemplo: febrero 25/2010                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ OAS - Sucursal Quevedo - Equador                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FINR085D01(dDtEmissao)
Local cDataEmissao := ""
Local aMes := {}

AADD(aMes,"Enero")
AADD(aMes,"Febrero")
AADD(aMes,"Marzo")
AADD(aMes,"Abril")
AADD(aMes,"Mayo")
AADD(aMes,"Junio")
AADD(aMes,"Julio")
AADD(aMes,"Agosto")
AADD(aMes,"Septiembre")
AADD(aMes,"Octubre")
AADD(aMes,"Noviembre")
AADD(aMes,"Diciembre")

If !Empty(dDtEmissao)
	cDataEmissao := aMes[Month(dDtEmissao)]+" "+StrZero(Day(dDtEmissao),2)+"/"+StrZero(Year(dDtEmissao),4)
EndIf

Return( cDataEmissao )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FINR085D02 บAutor  ณ Jose Lucas	    บ Data ณ   20/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retornar data de Validade no formato <Dia>/<NomeMes>/<ano> บฑฑ
ฑฑบ          ณ Exemplo: 25/FEBRERO/2010                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ OAS - Sucursal Quevedo - Equador                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FINR085D02(dDtValid)
Local cDataValid := ""
Local aMes := {}

AADD(aMes,"/ENERO/")
AADD(aMes,"/FEBRERO/")
AADD(aMes,"/MARZO/")
AADD(aMes,"ABRIL")
AADD(aMes,"MAYO")
AADD(aMes,"/JUNIO/")
AADD(aMes,"/JULIO/")
AADD(aMes,"/AGOSTO/")
AADD(aMes,"/SEPTIEMBRE/")
AADD(aMes,"/OCTUBRE/")
AADD(aMes,"/NOVIEMBRE/")
AADD(aMes,"/DICIEMBRE/")

If !Empty(dDtValid)
	cDataValid := StrZero(Day(LastDay(dDtValid)),2)+aMes[Month(dDtValid)]+StrZero(Year(dDtValid),4)
EndIf

Return( cDataValid )
