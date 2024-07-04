#include "RwMake.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "FINR085H.ch"

#define PIX_DIF_COLUNA_VALORES			275		// Pixel inicial para impressao dos tracos das colunas dinamicas
#define PIX_INICIAL_VALORES				470		// Pixel para impressao do traco vertical
#define PIX_EQUIVALENTE				  	340		// Pixel inicial para impressao das colunas dinamicas

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออ'อออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINR085   บ Autor ณ Totvs              บ Data ณ  06/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณCertificado de Reten็ใo do Imposto de Renda - EQUADOR     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFINR085                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FINR085H()

Local cPerg		:= "FI085H"  

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
Local clTitulo 				:= STR0001 //"Certificado de Reten็ใo do Imposto de Renda na Fonte - Equador" 
Local clDesc   			:= STR0001 //"Certificado de Reten็ใo do Imposto de Renda na Fonte - Equador" 
Local oCRReport

oCRReport:=TReport():New(clNomProg,clTitulo,cPerg,{|oCRReport| FINProc(oCRReport)},clDesc)
//oCRReport:SetLandscape()					// Formato paisagem
//oCRReport:oPage:nPaperSize	:= 8 		// Impressใo em papel A3
oCRReport:lHeaderVisible 			:= .F. 	// Nใo imprime cabe็alho do protheus
oCRReport:lFooterVisible 			:= .F.		// Nใo imprime rodap้ do protheus
oCRReport:lParamPage		  		:= .F.		// Nใo imprime pagina de parametros

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
Local nNumVias      := mv_par03
Local cNumCert 		:= ""  
Local cEndereco     := ""
Local cTelefone     := ""
Local cCidade       := ""
Local cDtEmissao    := ""         
Local cDtValidade   := ""
Local cRuc          := ""
Local cNotaFiscal   := ""
Local cAutoriza     := ""             
Local cNumeroCert   := ""
Local cNumAut       := ""
Local nTotalRetido  := 0.00
Local nCount        := 0        
Local lFIR085CP		:= ExistBlock("FIR085CP")
Local nPagIni  		:= 1
Local cStartPath	:= GetSrvProfString("StartPath","")
Local cBmp 			:= cStartPath + "lgrl"+cEmpAnt+".bmp" 	//Logo
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
cQuery += "FE_NUMAUT, "    
cQuery += "FE_TIPO, "  
cQuery += "FE_ORDPAGO, "   
cQuery += "FE_CONCEPT, "    
cQuery += "FE_VALBASE, "    
cQuery += "FE_ALIQ, "    
cQuery += "FE_RETENC, "    
cQuery += "A2_NOME, "     
cQuery += "A2_CGC, "    
cQuery += "A2_END, "   
cQuery += "A2_MUN, "  
cQuery += "A2_ESTADO "   
cQuery += "FROM "
cQuery += RetSqlName("SFE")+" SFE, "
cQuery += RetSqlName("SA2")+" SA2  "
cQuery += "WHERE "   
cQuery += "SFE.FE_FILIAL = '" + xFilial("SFE") + "' "
cQuery += "AND SA2.A2_FILIAL = '" + xFilial("SA2") + "' "
cQuery += "AND SFE.FE_NROCERT BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "  
cQuery += "AND SFE.FE_TIPO	IN	('I','R') "      		
cQuery += "AND SFE.FE_FORNECE = SA2.A2_COD " 				 
cQuery += "AND SFE.FE_LOJA = SA2.A2_LOJA "		 
cQuery += "AND SFE.D_E_L_E_T_ <> '*' " 
cQuery += "AND SA2.D_E_L_E_T_ <> '*' "
cQuery += "AND SFE.FE_TES < '500' AND SFE.FE_FORNECE <> '' "
cQuery += " ORDER BY FE_NROCERT, FE_EMISSAO "

cQuery := ChangeQuery( cQuery  )
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "PER",.T.,.T.)

TCSetField( "PER", "FE_EMISSAO",  "D", 08, 0 )
TCSetField( "PER", "FE_VALBASE",  "N", TamSX3( "FE_VALBASE" )[1], TamSX3( "FE_VALBASE" )[2] )
TCSetField( "PER", "FE_ALIQ"   ,  "N", TamSX3( "FE_ALIQ" )[1], TamSX3( "FE_ALIQ" )[2] )
TCSetField( "PER", "FE_RETENC" ,  "N", TamSX3( "FE_RETENC" )[1], TamSX3( "FE_RETENC" )[2] )

If lFIR085CP
	ExecBlock("FIR085CP",.F.,.F.)
EndIf

If ! lFIR085CP

	DbSelectArea( "PER" )
	PER->( DbGoTop() )
	While PER->(!Eof())
       AADD(aSFEItens,{PER->FE_NROCERT,PER->FE_EMISSAO,PER->FE_VALBASE,PER->FE_TIPO,PER->FE_CONCEPT,;
                       PER->FE_ALIQ,PER->FE_RETENC})
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
		    
			cEndereco   := AllTrim(SM0->M0_ENDCOB)
			cTelefone   := STR0018 +AllTrim(SM0->M0_TEL) //"Tel้fono: "
			cCidade     := AllTrim(SM0->M0_CIDCOB)
			cDtEmissao  := FINR085DtE(PER->FE_EMISSAO)         
			cRuc        := STR0002 +AllTrim(SM0->M0_CGC) //"RUC  "
			cNotaFiscal := Transform(PER->FE_NROCERT,"@R !999-999-99999999")
			cAutoriza   := STR0019 +Transform(AllTrim(PER->FE_NUMAUT),"9999999999") //"AUT. SRI.: "
	
			oCRReport:SetPageNumber(nPagIni) 
            
			If ! File(cBmp)
				oCRReport:Box(0080,0080,0400,0820) 				 //Box a Esquerda
			Else	   
				oCRReport:SayBitmap(0010, 0080,cBmp, 0760, 0460) //Logo
			EndIf
			
			oCRReport:Box(0080,1600,0400,2410) 					 //Box a Direita
		
			oCRReport:PrintText("",0100,0850)
			oCRReport:PrintText(STR0005		                  				,0100,1120) //"Matriz"
			oCRReport:PrintText(Subs(cEndereco,1,30)			    		,0150,0860)
			oCRReport:PrintText(cTelefone+" - "+cCidade						,0200,0865)
 
			//Informa็๕es apresentadas na cabe็alho, no Box Direito
			oCRReport:PrintText("",0100,0800)
			oCRReport:PrintText(cRuc						                ,0100,1770)
			oCRReport:Line(0160,1600,0160,2410)
			 
			oCRReport:PrintText(STR0003										,0180,1700) //"COMPROBANTE DE RETENCION"
			oCRReport:PrintText(cNotaFiscal									,0250,1710)
 			oCRReport:Line(0320,1600,0320,2410)
 
			oCRReport:PrintText(cAutoriza				      				,0340,1680)
	
			dbSelectArea("SA2")
			SA2->(dbSetOrder(1))
			SA2->(dbGoTop())
			SA2->(dbSeek(xFilial("SA2")+AvKey(PER->FE_FORNECE,"A2_COD")+AvKey(PER->FE_LOJA,"A2_LOJA")))
			
			oCRReport:PrintText(STR0007 + SA2->A2_NOME       ,0460,0080) //"Sr.(es): "
			oCRReport:PrintText(STR0020 + SA2->A2_CGC,0520,0080) //"No. R.U.C./C.I.: "
			oCRReport:PrintText(STR0021 + AllTrim(SA2->A2_END),0580,0080) 		//"Direcci๓n: "
           
			oCRReport:PrintText("Fecha de Emisi๓n: " + cDtEmissao,0460,1600)
			oCRReport:PrintText("Tipo comprobante de venta: " + "Facturas",0520,1600) 
			oCRReport:PrintText("No. comprobante de venta: " + Transform(PER->FE_NFISCAL,"@R 999-999-99999999"),0580,1600) 

			oCRReport:Box(0650,0080,1820,2410) 
			oCRReport:Line(0780,0080,0780,2410)//Linha Horizontal

			oCRReport:Line(0650,0350,1820,0350)//Linha Vertical 1
			oCRReport:Line(0650,0800,1820,0800)//Linha Vertical 2
			oCRReport:Line(0650,1150,1820,1150)//Linha Vertical 3
			oCRReport:Line(0650,1600,1820,1600)//Linha Vertical 4
			oCRReport:Line(0650,1950,1820,1950)//Linha Vertical 5

			oCRReport:PrintText(STR0022,0660,0090)			//"Exer.Fiscal" //"Ejercicio"
			oCRReport:PrintText(STR0023,0660,0360)		//"Base Calc.Ret."//"Base Imponible"
			oCRReport:PrintText("",0660,0810)					//""         
			oCRReport:PrintText(STR0024,0660,1160)			//"Cod.Imposto" //"C๓digo del"
			oCRReport:PrintText(STR0025,0660,1610)		//"% Retencao"//" % de Retenci๓n"
			oCRReport:PrintText(STR0026,0660,2120)				//"Vlr.Retenido"// "Valor"

			oCRReport:PrintText(STR0027,0700,0090)				//"Exer.Fiscal" //"Fiscal"
			oCRReport:PrintText(STR0028,0700,0360)	//"Base Calc.Ret."//"para la Retenci๓n"
			oCRReport:PrintText(STR0029,0700,0810)			//"Imposto" 
			oCRReport:PrintText(STR0029,0700,1160)			//"Cod.Imposto"
			oCRReport:PrintText(STR0030,0700,2120)			//"Vlr.Retenido"
 
			nlLin := 850
		                                                          
	        cNumeroCert  := PER->FE_NROCERT
			cNumAut      := PER->FE_NUMAUT
			nTotalRetido := 0.00        
			                     
			For nC := 1 To Len(aSFEItens)
				If aSFEItens[nC][1] == cNumeroCert
					cExercicio := StrZero(Year(aSFEItens[nC][2]),4)
					oCRReport:PrintText(Transform(cExercicio,"9999")                            ,nlLin,0100)
					oCRReport:PrintText(Transform(aSFEItens[nC][3],"@E 999,999,999.99")			,nlLin,0380)
					oCRReport:PrintText(IIF(SubStr(aSFEItens[nC][4],1,1)=="I","IVA","RENTAS")	,nlLin,0840)
					oCRReport:PrintText(aSFEItens[nC][5]         								,nlLin,1200)
					oCRReport:PrintText(Transform(aSFEItens[nC][6],"@E %999.99")				,nlLin,1630)
					oCRReport:PrintText(Transform(aSFEItens[nC][7],"@E 999,999,999.99")			,nlLin,2000)
					nTotalRetido += aSFEItens[nC][7]    
					nlLin += 40
				EndIf
			Next nC

 			oCRReport:Line(1740,1600,1740,2410)
			oCRReport:PrintText(STR0031														,1750,1620) //"VALOR RETENIDO"
			oCRReport:PrintText(Transform(nTotalRetido,"@E 999,999,999.99")								,1750,2000)
		                          
			dbSelectArea("SFP")
			dbSetOrder(1)
			SFP->(dbSetOrder(7))
			If SFP->(dbSeek(xFilial("SFP")+cFilAnt+AvKey(PER->FE_NUMAUT,"FP_NUMAUT")))
				cDtValidade := FINR085DtV(SFP->FP_DTAVAL)
			EndIf                       
			oCRReport:PrintText(STR0032 + cDtValidade,1830,0092) //"VALIDO HASTA: "
			If nCount == 1
				oCRReport:PrintText(STR0033,1830,1620) //"1a:SUJETO PASIVO RETENIDO"
            ElseIf nCount == 2                                                                                 
				oCRReport:PrintText(STR0034,1830,1620) //"2a:AGENTE DE RETENCION"
			Else
				oCRReport:PrintText(STR0035,1830,1620) //"3a:ARCHIVO"
            EndIf

			oCRReport:Line(2050,0080,2050,0810)
			oCRReport:Line(2050,1600,2050,2410)
			
			oCRReport:PrintText(STR0036,2070,0150) //"FIRMA AGENTE DE RETENCION"
			oCRReport:PrintText(STR0037,2070,1680) //"FIRMA SUJETO PASIVO RETENIDO"

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
ฑฑบPrograma  ณ FINR085tE บAutor  ณ Jose Lucas	    บ Data ณ   20/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retornar a data de Emissao no formato <cNomeMes><Dia>/<ano>บฑฑ
ฑฑบ          ณ Exemplo: febrero 25/2010                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ OAS - Sucursal Quevedo - Equador                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FINR085DtE(dDtEmissao)
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
ฑฑบPrograma  ณ FINR085DtV บAutor  ณ Jose Lucas	    บ Data ณ   20/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retornar data de Validade no formato <Dia>/<NomeMes>/<ano> บฑฑ
ฑฑบ          ณ Exemplo: 25/FEBRERO/2010                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ OAS - Sucursal Quevedo - Equador                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FINR085DtV(dDtValid)
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
