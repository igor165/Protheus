#Include "Protheus.ch"
#include "OGR190.CH"


/*{Protheus.doc} OGR190
Relatório de Pesagens Avulsas
@type function
@author roney.maia
@since 13/10/2016
@version 1.0
*/

Function OGR190(cAlias, nReg, nOpcx)

	local oReport
	local cPerg := PadR(STR0001,10)
	oReport := reportDef(cPerg)
	oReport:printDialog()
	
Return
 
Static Function reportDef(cNome)
	local oReport
	Local cTitulo := STR0002
	Local cDesc := STR0003
	
	oReport := TReport():New(cNome, cTitulo, , {|oReport| PrintReport(oReport)}, cDesc) // Instanciação do objeto TReport
	oReport:SetPortrait(.T.) // Define a orientação default
	oReport:HideParamPage()
	oReport:HideHeader() 
	oReport:HideFooter() 
	oReport:SetTotalInLine(.F.)
	oReport:DisableOrientation() // Bloqueia a escolha de orientação da página
	oReport:nFontBody := 8 // Tamanho da fonte
	// oreport:cfontbody:="Arial"   <- Define o tipo de fonte ou tipagem a ser utilizado.
 	
 
return (oReport)
 
Static Function PrintReport(oReport)

	Local nPageWidth := 2435 // Largura da Página
	Local cImageTes := STR0004
	Local nx := 1
	Local nLinPC := 0
	Local nEmp := 0
	Local cMascara := ""
	Local cUsrName := UsrRetName(RetCodUsr())
	Local cCpf     := IIf(FieldPos("NJH_CGC") > 0,NJH->NJH_CGC," ")
	
	If !Empty(cCpf) .And. Len(AllTrim(cCpf))<14
		cMascara := "@R 999.999.999-99999" //Acrescentados 3 digitos p/ realizar a troca CPF/CNPJ 
	Else
		cMascara := "@R 99.999.999/9999-99"
	EndIf
 
	If !File(cImageTes)
		cImageTes = GetSrvProfString('Startpath','') + cImageTes
	EndIf
	
	
	For nx := 1 To 2

		oReport:Box( 020 + nLinPC , 020 ,  440 + nLinPC, 1220 ) // Criação do box de cada seção
		oReport:Box( 020 + nLinPC, 1220 , 440 + nLinPC, nPageWidth - 2 )
		oReport:Box( 440 + nLinPC, 020 , 680 + nLinPC, nPageWidth - 2 )
		oReport:Box( 680 + nLinPC, 020 , 1000 + nLinPC, nPageWidth - 2 )
		oReport:Box( 1000 + nLinPC, 020 , 1360 + nLinPC, nPageWidth - 2 )
			
			
		nLinPC := oReport:Row()
		If nLinPC > 10  // Condicional para segunda impressao
			nLinPC := nLinPC + 90
			nEmp := 30
		EndIf 
			
		// ----------------------------------------------------------------------------
			
		oReport:SkipLine() // Pula Linha
		oReport:PrintText(STR0005 ,nLinPC + nEmp,30)
		oReport:PrintText(STR0006 ,nLinPC + 30,1240)
			
		oReport:SkipLine()
		JumpLines(oReport) // Salta duas linhas para o uso da fonte tamanho 10.
			
		nLinPC := oReport:Row()
		oReport:PrintText(AllTrim(SM0->M0_NOMECOM),nLinPC,30) // "Empresa:"
		oReport:PrintText(STR0007 + AllTrim(NJH->NJH_CODENT) + " " + STR0008 + AllTrim(NJH->NJH_LOJENT),nLinPC,1240)
			
		JumpLines(oReport)
			
		nLinPC := oReport:Row()
		oReport:PrintText(STR0009 + SubStr(AllTrim(SM0->M0_ENDENT), 0, 49), nLinPC, 30)
						
		JumpLines(oReport)
			        
		nLinPC := oReport:Row()
		oReport:PrintText(STR0010 + Trans(SM0->M0_CEPENT,PesqPict("SM0","M0_CEPENT"))+Space(2)+ STR0011 + SubStr(RTRIM(SM0->M0_CIDENT), 0, 27) + " " + STR0012 + AllTrim(SM0->M0_ESTENT) ,nLinPC,30)
		oReport:PrintText(STR0013 + AllTrim(NJH->NJH_NOMENT),nLinPC,1240)
			
		JumpLines(oReport)
			
		nLinPC := oReport:Row()
		oReport:PrintText(STR0014 + AllTrim(SM0->M0_TEL) + Space(2) + STR0015 + AllTrim(SM0->M0_FAX) ,nLinPC,30)
		oReport:PrintText(STR0016 + AllTrim(NJH->NJH_NLJENT),nLinPC,1240)
			
		JumpLines(oReport)
			
		nLinPC := oReport:Row()
		oReport:PrintText(STR0017 + Transform(SM0->M0_CGC,PesqPict("SM0","M0_CGC")) +Space(2)+ STR0018 + AllTrim(SM0->M0_INSC) ,nLinPC,30)
			
		// ----------------------------------------------------------------------------
			
		oReport:PrintText(STR0019 ,nLinPC + 100, 30)
			
		oReport:SkipLine()
		JumpLines(oReport)
			
		nLinPC := oReport:Row()
		oReport:PrintText(STR0020 + AllTrim(NJH->NJH_CODPAV) ,nLinPC,30)
			
		JumpLines(oReport)
			
		nLinPC := oReport:Row()
		oReport:PrintText(STR0021 + AllTrim(NJH->NJH_CODSAF) + Space(6) + STR0022 + AllTrim(NJH->NJH_DESPRO) + Space(6) + STR0023 + AllTrim(NJH->NJH_UM1PRO),nLinPC,30)
			
		// ----------------------------------------------------------------------------
			
		oReport:PrintText(STR0024 ,nLinPC + 100, 30)
			
		oReport:SkipLine()
		JumpLines(oReport)
			
		nLinPC := oReport:Row()
		oReport:PrintText(STR0025 + PadR(Transform(NJH->NJH_PESO1,PesqPict("NJH","NJH_PESO1")), 14) + Space(6) + STR0026 + DtoC(NJH->NJH_DATPS1) + Space(6) + STR0027 + NJH->NJH_HORPS1 ,nLinPC,30)
			
		JumpLines(oReport)
			
		nLinPC := oReport:Row()
		oReport:PrintText(STR0028 + PadR(Transform(NJH->NJH_PESO2,PesqPict("NJH","NJH_PESO2")), 14) + Space(6) + STR0026 + DtoC(NJH->NJH_DATPS2) + Space(6) + STR0027 + NJH->NJH_HORPS2 ,nLinPC,30)
		
		JumpLines(oReport)
			
		nLinPC := oReport:Row()
		oReport:PrintText(STR0029 + PadR(Transform(NJH->NJH_PSSUBT, PesqPict("NJH", "NJH_PSSUBT")), 14) ,nLinPC,30)
			
		// ----------------------------------------------------------------------------
			
		oReport:PrintText(STR0030 ,nLinPC + 100, 30)
			
		oReport:SkipLine()
		JumpLines(oReport)
			
		nLinPC := oReport:Row()
		oReport:PrintText(STR0031 + AllTrim(NJH->NJH_PLACA) + Space(6) + ALLTRIM(STR0032) + IIF( EMPTY(NJH->NJH_CODMOT) ,"", ALLTRIM(NJH->NJH_CODMOT) + " -" ) + Space(1) + AllTrim(NJH->NJH_NOMMOT)  +  Space(6) + STR0036 + Transform(cCpf ,cMascara) ,nLinPC,60)
			
		JumpLines(oReport)
			
		nLinPC := oReport:Row()
		oReport:PrintText(ALLTRIM(STR0033) + IIF( EMPTY(NJH->NJH_CODTRA) ,"", ALLTRIM(NJH->NJH_CODTRA) + " -" ) + Space(1) + NJH->NJH_NOMTRA,nLinPC,30)
			
		JumpLines(oReport)
			
		nLinPC := oReport:Row()
		oReport:PrintText(STR0034 + SubStr(AllTrim(NJH->NJH_OBS), 0, 109),nLinPC,30)
		
		JumpLines(oReport)
			
		nLinPC := oReport:Row()
		oReport:PrintText(SubStr(AllTrim(NJH->NJH_OBS), 110, 128),nLinPC,30)
			
		JumpLines(oReport)
			
		nLinPC := oReport:Row()
		oReport:PrintText(STR0035 + cUsrName, nLinPC + 70, 30)
			
		JumpLines(oReport)
			
		nLinPC := oReport:Row()
		If nEmp != 30 // Condicional para executar apenas uma vez a primeira impressão do recorte
		oReport:SayBitmap(nLinPc, 30, cImageTes, 60 , 60) // Adicão da imagem da tesoura em formato .bmp
		oReport:PrintText(Replicate("-", 140), nLinPC, 60) // Print do pontilhado para recorte
		EndIf
		
		nLinPC := nLinPC + 80
		
	next nx	
		
		
Return

Static Function JumpLines(oReport)
	oReport:SkipLine()
	oReport:SkipLine()

Return
