#Include "Protheus.ch"
#Include "TECA997.ch"

//------------------------------------------------------------------------------
/*/
{Protheus.doc} TECA997

Exportação da planilha de preço para o excel

@sample 	TECA997() 

@param		oFWSheet -> Objeto da classe FWSheet
	
@since		24/10/2013       
@version	P11.9
/*/
//------------------------------------------------------------------------------
Function TECA997(oFWSheet)

Local oExcel		:= Nil
Local cTitPlan 	:= STR0001 //"Planilha de Cálculo"
Local cPlan		:= ""
Local aDados		:= {}
Local nY			:= 0
Local nW			:= 0
Local cFile		:= ""
Local xValor		:= ""

	oExcel := FWMSExcel():New() // Define o objeto
	oExcel:AddworkSheet(cTitPlan) // Define o titulo da planilha 
	oExcel:AddTable (cTitPlan,cPlan)
	
	For nY := 1 To Len(oFWSheet:aCells) //linha 
		For nW := 2 To Len(oFWSheet:aCells[nY]) //Coluna
			xValor := oFWSheet:aCells[nY][nW]
			If nY == 1
				oExcel:AddColumn(cTitPlan,cPlan,Iif(ValType(xValor) == "U","",xValor),2,1)
			Else
				aAdd(aDados,Iif(ValType(xValor) == "U","",xValor))
			EndIf 
		Next nW
		If nY != 1
			oExcel:AddRow(cTitPlan,cPlan,aDados)		
			aDados := {}
		EndIf
	Next nY

	oExcel:SetTitleFrColor('#000000') //Cor de fonte do Titulo (Preto)
	oExcel:SetTitleBgColor('#FFFFFF') //Cor de preenchimento do Titulo (Branco)
	oExcel:SetHeaderBold(.F.) //configuração "Negrito" retirada 
	
	oExcel:SetFrColorHeader('#000000') //Cor de fonte do Cabeçalho (Preto)
	oExcel:SetBgColorHeader('#FFFFFF') //Cor de preenchimento do Cabeçalho (Branco)
	
	oExcel:SetLineFrColor('#000000') //Cor de fonte da linha (Preto)
	oExcel:SetLineBgColor('#FFFFFF') //Cor de preenchimento da linha (Branco)
	
	oExcel:Set2LineFrColor('#000000') //Cor de fonte da linha 2 (Preto)
	oExcel:Set2LineBgColor('#FFFFFF') //Cor de preenchimento da linha 2 (Branco) 
	
	oExcel:Activate()
	
	cFile := cGetFile(STR0002,STR0003,1,,.F.,nOR(GETF_LOCALHARD,GETF_LOCALFLOPPY),.T.,.T.) //'Arquivo XML|*.xml'#'Salvar Planilha'
	
	If At('.xml',cFile) == 0
		cFile := cFile+'.xml'
	EndIf
	
	oExcel:GetXMLFile(cFile)

Return