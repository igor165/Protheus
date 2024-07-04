#INCLUDE "MATC110.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATC110   º Autor ³ Paulo Eduardo      º Data ³  04/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para geracao de consulta/relatorio de Livros Fiscaisº±±
±±º          ³ de Compras/Vendas.                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±º         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºProgramador ³Data    ³ BOPS     ³ Motivo da Alteracao                  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±Oscar G.     ³08/03/19³DMINA-6169³Manejo correcto de códigos con letra  º±±
±±º            ³        ³          ³para campos de libros fiscales. ARG   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Matc110()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local   cPerg := "MTC110" 
Local 	aObjects,aInfo,aPosObj
Local 	aSizeAut := MsAdvSize(,.F.,400)
Local	cCadastro := "",cCodImp := "",cCpoLivro := ""
Local	oMainWnd,oList,oCombo   
Local	nWidth := 0,nC:=0,nD:=0,nPosTipo:=0
Local	aTiposPE := {}
Local 	nI:=0, nX:=0, nK:=0, nJ:=0
Local   lAutomato := IsBlind()
Private	aHeadBrow,aHeader,aItens,aButtons,aValores:={},aMarcado:={}
Private aTipos,aHeadBase,aHeadVal,aImpostos,aHeadRes,aTiposFac,aCposDic
Private cCbox := ""
Private oDlg
Private lDic := .F.           
Private nSel := 1,nPosBrow:=0
Private lContCons := .T.
Private cImpostos := ""
      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra parametros para configuracao da rotina                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Pergunte(cPerg,.T.)
	If !mv_par03 $ "01|02|03|04|05|06|07|08|09|10|11|12"
		Alert(STR0001) //"Mes invalido!"
		Return(.F.)
	EndIf	
Else
	Return(.F.)	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta array de Tipos de documentos para Combobox     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
aTiposFac := {}
aTipos    := {}
AAdd(aTiposFac,{"NF","NCP","NDP","NCI","NDI","NCC","NDC","NCE","NDE"})
AAdd(aTiposFac,{STR0002,STR0003,STR0004,; //"NF   - Normal"###"NCP - Nota Credito Proveedor"###"NDP - Nota Debito Proveedor"
		STR0005,STR0006,STR0007,; //"NCI  - Nota Credito Interna"###"NDI  - Nota Debito Interna"###"NCC - Nota Credito Cliente"
		STR0008,STR0009,STR0010}) //"NDC - Nota Debito Cliente"###"NCE - Nota Credito Externa"###"NDE - Nota Debito Externa"
AAdd(aTiposFac,{'','','','','','','','',''})	
AAdd(aTiposFac,{'','C','C','C','C','V','V','V','V'})	

If ExistBlock("MTC110TP")
	aTiposPE := ExecBlock("MTC110TP",.F.,.F.,{aTiposFac[1],aTiposFac[3]})
	
	If Len(aTiposPE) > 0 .and. ValType(aTiposPE) == "A"
		If Len(aTiposPE[1]) > 0 .and. ValType(aTiposPE[1]) == "A"
			For nC:=1 To Len(aTiposPE[1])
				nPosTipo := Ascan(aTiposFac[1],aTiposPE[1][nC][1])
				If nPosTipo > 0
					aTiposFac[3][nPosTipo] := aTiposPE[1][nC][2]
				EndIf
			Next
		EndIf
		
		If ValType(aTiposPE[2]) == "A" .and. Len(aTiposPE[2]) > 0
			For nD:=1 To Len(aTiposPE[2])
				If ValType(aTiposPE[2][nD][3]) == "C" .and. ValType(aTiposPE[2][nD][3]) $ "C|V| "
					AAdd(aTiposFac[1],aTiposPE[2][nD][1])
					AAdd(aTiposFac[2],aTiposPE[2][nD][2])
					AAdd(aTiposFac[3],aTiposPE[2][nD][3])
					AAdd(aTiposFac[4],aTiposPE[2][nD][4])
				Else	
					Alert(STR0041 + aTiposPE[2][nD][1]+ STR0042)	
				EndIf
			Next
		EndIf
	EndIf   
EndIf		

For nX:=1 To Len(aTiposFac)
	AAdd(aTipos,{})
Next

For nX:=1 To Len(aTiposFac[4])
	If aTiposFac[4][nX] == IIf(mv_par01 == 1,'C','V') .or. aTiposFac[4][nX] == ""
		AAdd(aTipos[1],aTiposFac[1][nX])
		AAdd(aTipos[2],aTiposFac[2][nX])
		AAdd(aTipos[3],aTiposFac[3][nX])
		AAdd(aTipos[4],aTiposFac[4][nX])
	EndIf	
Next  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta array de impostos                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SFB")
DbSetOrder(1)
DbGoTop()

aImpostos := {}
aAuxImp   := {}
SFB->(dbSeek(xFilial("SFB")))
While !SFB->(EOF()) .and. SFB->FB_FILIAL == xFilial("SFB")                 
	AAdd(aAuxImp,{SFB->FB_CPOLVRO,SFB->FB_CODIGO})
	DbSkip()
EndDo          

aSort(aAuxImp,,,{|x,y| x[1] < y[1]})

For nI:=1 To Len(aAuxImp)
	nPos := AScan(aImpostos,{|x| x[1] = aAuxImp[nI][1]})
	If nPos == 0
		AAdd(aImpostos,{aAuxImp[nI][1],aAuxImp[nI][2],0,0})
		cImpostos += aAuxImp[nI][1] + "|"
   	Else
   		aImpostos[nPos,2] += "/" + aAuxImp[nI][2]
   	Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a Header com os campos principasi e separa os    ³
//³campos de base e valor de impostos em arrays diferentes³
//³aHeadBase e aHeadVal                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SF3")
nUsado    := 0
aHeader   := {}
aCposDic  := {}
aHeadBase := {}
aHeadVal  := {}
While !Eof() .And. (x3_arquivo == "SF3")   
  	If !SubStr(SX3->X3_CAMPO,4,6) $ "BASIMP|VALIMP|ALQIMP|RETIMP|REPROC"
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			nUsado:=nUsado+1
			Aadd(aHeader,{Trim(X3TITULO()),SX3->X3_CAMPO,SX3->X3_PICTURE,			;
				SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,	;
				SX3->X3_F3,SX3->X3_CONTEXT,nPosBrow})
			If AllTrim(SX3->X3_CAMPO) $ "F3_ENTRADA|F3_NFISCAL|F3_SERIE|F3_CLIEFOR|F3_LOJA|F3_EXENTAS"	
				nSel := 0
			Else
				nSel := 1
			EndIf		
			AAdd(aCposDic,{nSel,AllTrim(RetTitle(AllTrim(SX3->X3_CAMPO))),X3Descric()})	
		Endif          
	ElseIf SubStr(SX3->X3_CAMPO,4,6) $ "BASIMP"
			If SubStr(SX3->X3_CAMPO,10,1) $ cImpostos
				nUsado:=nUsado+1
				Aadd(aHeadBase,{Trim(X3TITULO()),SX3->X3_CAMPO,SX3->X3_PICTURE,			;
					SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,	;
					SX3->X3_F3,SX3->X3_CONTEXT})	
			EndIf		
	ElseIf SubStr(SX3->X3_CAMPO,4,6) $ "VALIMP"
			If SubStr(SX3->X3_CAMPO,10,1) $ cImpostos
				nUsado:=nUsado+1
				Aadd(aHeadVal,{Trim(X3TITULO()),SX3->X3_CAMPO,SX3->X3_PICTURE,			;
					SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,	;
					SX3->X3_F3,SX3->X3_CONTEXT})	
			EndIf				
  	EndIf	
	dbSkip()
End

// Ordena para coincidir con aImpostos
aSort(aHeadBase,,,{|x,y| x[2] < y[2]})
aSort(aHeadVal,,,{|x,y| x[2] < y[2]})
        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta array de posicionamento de objetos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aObjects := {}
AAdd( aObjects, { 00, 20, .T., .F. } )
AAdd( aObjects, { 50, 50, .T., .T., .T. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta array de botoes da Enchoicebar    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
aButtons := {}
AAdd(aButtons,{"RELATORIO",{||M110ImpLivro(oCombo)},STR0011}) //"Imprime Livro"
AAdd(aButtons,{"bmpincluir",{||M110Resumo()},STR0012}) //"Resumo"
AAdd(aButtons,{"BMPCPO",{||M110Dic("SF3")},STR0013}) //"Dicionario"

While lContCons
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta array somente com os titulos dos campos e monta o bline do Listbox          |
	//|Monta array com o tamanho dos campos                                              |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    aTam	  := {}
	aHeadBrow := {}   
	For nI :=1 To Len(aHeader)
		If aHeader[nI][8] == "D"
			nWidth  := Max(aHeader[nI][4],Len(AllTrim(aHeader[nI][1])))*5
		Else
			nWidth	:= Max(aHeader[nI][4],Len(AllTrim(aHeader[nI][1])))*4	
		EndIf
		If lDic
			aHeader[nI][Len(aHeader[nI])] := 0
			If aCposDic[nI][1] >=0
				AAdd(aHeadBrow,aHeader[nI][1])
				aHeader[nI][Len(aHeader[nI])] := Len(aHeadBrow)
				AAdd(aTam,nWidth)
			EndIf	
		Else	
			AAdd(aHeadBrow,aHeader[nI][1])  
			aHeader[nI][Len(aHeader[nI])] := Len(aHeadBrow)
			AAdd(aTam,nWidth)
		EndIf	
	Next	

	If mv_par04 > 1	
		For nJ:=1 To Len(aImpostos)
			AAdd(aHeadBrow,aImpostos[nJ][2]+" "+STR0014) //"(Base)"
			AAdd(aHeadBrow,aImpostos[nJ][2]+" "+STR0015) //"(Valor)"
		Next
	Else
		AAdd(aHeadBrow,aImpostos[1][2]+" "+STR0014) //"(Base)"
		AAdd(aHeadBrow,aImpostos[1][2]+" "+STR0015) //"(Valor)"
		If Len(aImpostos) > 1
			AAdd(aHeadBrow,STR0016) //"Valor Outros Impostos"
		EndIf	
	EndIf
	
	lContCons := .F.	
	                                  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta array com os itens vazio³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aItens := {}
	aAdd(aItens,Array(Len(aHeadBrow)))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta janela principal                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCadastro := STR0017 + IIf(mv_par01 == 1,STR0018,STR0019) //"Livros Fiscais de "###"Compras"###"Vendas"
             
	DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro OF oMainWnd PIXEL

	@ aPosObj[1][1],aPosObj[1][2] TO aPosObj[1][3],aPosObj[1][4] LABEL '' OF oDlg PIXEL
	@ aPosObj[1][1]+7,aPosObj[1][2]+10 SAY oDoc VAR STR0020 OF oDlg PIXEL //"Documento"
	@ aPosObj[1][1]+5,aPosObj[1][2]+60 COMBOBOX oCombo VAR cCbox ITEMS aTipos[2] SIZE 100,30 OF oDlg ON CHANGE MsAguarde({|| M110SlcItem(@oList,oCombo)},STR0024,cCbox) PIXEL

	oList:=TWBrowse():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4],,aHeadBrow,aTam,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oList:SetArray(aItens)
	oList:bLine:={ || RetLine(oList:nAT) }
	IF !lAutomato //Tratamiento para scripts automatizados @Nancy González 17/08/2018
	   ACTIVATE MSDIALOG oDlg ON INIT (MsAguarde({|| M110SlcItem(@oList,oCombo)},STR0024,cCbox),EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End(),lFirst:=.F.},,aButtons)) CENTERED
	Else
	  M110SlcItem(@oList,oCombo)
	  M110ImpLivro(oCombo)
	  Exit
	Endif

EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M110RESUMOºAutor  ³PauloEduardo        º Data ³  06/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para mostrar tela de resumo com os totais para cada  º±±
±±º          ³tipo de documento.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                    

Function M110Resumo()
	 
Local 	cCadastro := STR0012,cArqTrab := "",cCond := "",cChave:="" //"Resumo"
Local 	cAliasSF3 := "",cQuery := "",cCpoData:= "",cTipo := ""
Local 	nCont := 0,nOrdSF3 := 0,nValBase:=0,nValImp:=0,nTotLinha:=0,nIsento:=0,nInc:=1,nX:=0
Local 	oDlgRes,oMainWnd,oList
Local 	aBaseTemp,aValTemp,aTotal:={}
Local	nI:=0, nJ:=0, nK:=0
Local	aArea := GetArea()
Private aResumo
                                          
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Header do browse de Resumo      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ              
aHeadRes := {}
                 
AAdd(aHeadRes,STR0020) //"Documento"
AAdd(aHeadRes,STR0021) //"Quantidade"
AAdd(aHeadRes,STR0022) //"Isento"

If mv_par04 > 1	
	For nJ:=1 To Len(aImpostos)
		AAdd(aHeadRes,aImpostos[nJ][2]+" "+STR0014) //"(Base)"
		AAdd(aHeadRes,aImpostos[nJ][2]+" "+STR0015) //"(Valor)"
	Next
Else
	AAdd(aHeadRes,aImpostos[1][2]+" "+STR0014) //"(Base)"
	AAdd(aHeadRes,aImpostos[1][2]+" "+STR0015) //"(Valor)"
	If Len(aImpostos) > 1
		AAdd(aHeadRes,STR0016) //"(Valor Outros Impostos)"
	EndIf	
EndIf	
              
AAdd(aHeadRes,STR0023) //"Total"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta itens do Resumo                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
#IFDEF TOP
	aResumo 	:= {}
	For nX:=1 To Len(aTipos[1])
	
	cAliasSF3:="F3TMP"
	If Select(cAliasSF3)<>0
   		DbSelectArea(cAliasSF3)
   		DbCloseArea()
	Endif            

	cQuery := "SELECT * FROM "+RetSqlName("SF3")+" "+cAliasSF3+" "
    cQuery += "WHERE F3_FILIAL='"+ xFilial("SF3")+"'"+" AND RTRIM(F3_ESPECIE) = '"+ aTipos[1][nX]+"'"
    cQuery += "AND F3_TIPOMOV ='"+ IIf(mv_par01 == 1,'C','V') +"'AND "
    cQuery += "SUBSTRING(F3_ENTRADA,1,6) = '" + mv_par02+mv_par03 + "'"
	If !Empty(aTipos[3][nX])
		cQuery += " AND " + aTipos[3][nX]
    EndIf
    cQuery +=" AND D_E_L_E_T_<>'*' ORDER BY " 
    cQuery +="F3_ENTRADA,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_CFO"
    cQuery :=ChangeQuery(cQuery)
	MsAguarde({|| dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSF3,.F.,.T.)},STR0024)
	For nI:=1 To Len(aHeader)
		If aHeader[nI][8] == "D"
			TCSetField(cAliasSF3,AllTrim(aHeader[nI][2]),"D",8,0)
		EndIf		                     
	Next
#ELSE
	cAliasSF3:="SF3"
	DbSelectArea(cAliasSF3)
	DbGoTop()         

	nOrdSF3 := IndexOrd()
            
	aResumo 	:= {}
	For nX:=1 To Len(aTipos[1])

		cCond := cAliasSF3+"->F3_FILIAL == '"+ xFilial(cAliasSF3) + "'.and. AllTrim("+cAliasSF3+"->F3_ESPECIE) == '"+ aTipos[1][nX]+"'"
		cCond += ".and. "+cAliasSF3+"->F3_TIPOMOV =='"+ IIf(mv_par01 == 1,'C','V') +"'.and."
		cCond += "SubStr(Dtos("+cAliasSF3+"->F3_ENTRADA),1,6) == '" + mv_par02+mv_par03 + "'"
		If !Empty(aTipos[3][nX])
			cCond += " .and. " + aTipos[3][nX]
    	EndIf     
		cArqTrab := CriaTrab(Nil,.F.)
		IndRegua(cAliasSF3,cArqTrab,IndexKey(),,cCond,STR0024) //"Selecionando Facturas"
#ENDIF	    
		DbGoTop()
		nCont   	:=0
		nValBase	:=0
		nValImp 	:=0
		nIsento		:=0
		nTotLinha	:=0
		aBaseTemp	:= {}
		aValTemp	:= {}

   		If aTipos[4][nX] == IIf(mv_par01 == 1,'C','V').or. aTipos[4][nX] == ''
			AAdd(aResumo,{aTipos[2][nX],nCont,nIsento,nValBase,nValImp})
			If mv_par04 > 1
				For nI:=2 To Len(aImpostos)
					AAdd(aResumo[Len(aResumo)],0)
					AAdd(aBaseTemp,0)
					AAdd(aValTemp,0)
		   		Next	
			ElseIf Len(aImpostos) > 1
				AAdd(aResumo[Len(aResumo)],0)	
				AAdd(aValTemp,0)
			EndIf	
		EndIf	

		While !(cAliasSF3)->(EOF())
			nCont++
			cChave := (cAliasSF3)->F3_FILIAL+DTOS((cAliasSF3)->F3_ENTRADA)+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+; 
				(cAliasSF3)->F3_CFO+(cAliasSF3)->F3_ESPECIE+(cAliasSF3)->F3_TIPOMOV
			nValBase += (cAliasSF3)->F3_BASIMP1
			nValImp  += (cAliasSF3)->F3_VALIMP1
			nIsento  += (cAliasSF3)->F3_EXENTAS
			cTipo	 := (cAliasSF3)->F3_TIPO
			If Len(aImpostos)>1
				If mv_par04 > 1
					For nI:=1 To Len(aImpostos)-1
						If cTipo <> "D"
							aBaseTemp[nI] += FieldGet(aImpostos[nI+1][3])
							aValTemp[nI]  += FieldGet(aImpostos[nI+1][4])
						Else                                              
							aBaseTemp[nI] += FieldGet(aImpostos[nI+1][3]) * -1
							aValTemp[nI]  += FieldGet(aImpostos[nI+1][4]) * -1
						EndIf	
					Next               
				ElseIf Len(aImpostos) > 1
					For nI:=1 To Len(aImpostos)-1
						If cTipo <> "D"
							aValTemp[1] += FieldGet(aImpostos[nI+1][4])
						Else                                            
							aValTemp[1] += FieldGet(aImpostos[nI+1][4]) * -1
						EndIf	
					Next
				EndIf	
			EndIf	
			DbSkip()	
			If cChave <> (cAliasSF3)->F3_FILIAL+DTOS((cAliasSF3)->F3_ENTRADA)+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+; 
				(cAliasSF3)->F3_CFO+(cAliasSF3)->F3_ESPECIE+(cAliasSF3)->F3_TIPOMOV      
				If cTipo <> "D"
					aResumo[Len(aResumo)] := {aTipos[2][nX],nCont,nIsento,nValBase,nValImp}
				Else
					aResumo[Len(aResumo)] := {aTipos[2][nX],nCont,nIsento*-1,nValBase*-1,nValImp*-1}
				EndIf	
			Else 
				nValBase += (cAliasSF3)->F3_BASIMP1
				nValImp  += (cAliasSF3)->F3_VALIMP1
				nIsento  += (cAliasSF3)->F3_EXENTAS
				If Len(aImpostos)>1
					If mv_par04 > 1                
						nInc:=2
						For nI:=1 To Len(aImpostos)-1
							If cTipo <> "D"
						   		aBaseTemp[nI] += FieldGet(aImpostos[nInc][3])
								aValTemp[nI]  += FieldGet(aImpostos[nInc][4])
							Else                                              
								aBaseTemp[nI] += FieldGet(aImpostos[nInc][3]) * -1
								aValTemp[nI]  += FieldGet(aImpostos[nInc][4]) * -1
							EndIf	
							nInc++
						Next                                          
					Else
						For nI:=2 To Len(aImpostos)
							For nJ:=1 To Len(aValTemp)
								If cTipo <> "D"
									aValTemp[nJ] += FieldGet(aImpostos[nI][4])
								Else                                           
									aValTemp[nJ] += FieldGet(aImpostos[nI][4]) * -1
								EndIf	
							Next
						Next                        
					EndIf	
				EndIf	
				If cTipo <> "D"
					aResumo[Len(aResumo)] := {aTipos[2][nX],nCont,nIsento,nValBase,nValImp}
				Else
					aResumo[Len(aResumo)] := {aTipos[2][nX],nCont,nIsento*-1,nValBase*-1,nValImp*-1}
				EndIf	
				DbSkip()	
			EndIf	    
		EndDo
		If mv_par04 > 1
			For nK:=1 To Len(aValTemp)
				AAdd(aResumo[Len(aResumo)],aBaseTemp[nK])
				AAdd(aResumo[Len(aResumo)],aValTemp[nK])
			Next
		ElseIf Len(aImpostos) > 1
			AAdd(aResumo[Len(aResumo)],0)	
			For nK:=1 To Len(aValTemp)
				aResumo[Len(aResumo)][Len(aResumo[Len(aResumo)])] += aValTemp[nK]
			Next
		EndIf	
		For nI:=1 To Len(aValTemp)
			nTotLinha += aValTemp[nI]
		Next	       
		AAdd(aResumo[Len(aResumo)],aResumo[Len(aResumo)][5]+nTotLinha+aResumo[Len(aResumo)][3])
	Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Apresenta a linha de Totais Gerais no browse de Resumo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aResumo)>0 
	AAdd(aTotal,Array(Len(aHeadRes)))
	aTotal[1][1]:= STR0038 // "Total Geral"
	For nI:=2 To Len(aHeadRes)
		aTotal[1][nI] := 0
	Next

	For nJ:=1 To Len(aResumo)	
		For nK:=2 To Len(aHeadRes)
			aTotal[1][nK] += aResumo[nJ][nK]
		Next	
	Next  
	AAdd(aResumo,Array(Len(aHeadRes)))
	AAdd(aResumo,aTotal[Len(aTotal)])
EndIf		

#IFDEF TOP                                              
	DbSelectArea(cAliasSF3)
	DbCloseArea()
#ELSE	
	RetIndex(cAliasSF3)
	(cAliasSF3)->(DbSetOrder(nOrdSF3))
	cArqTrab+=OrdBagExt()
	File(cArqTrab)
	Ferase(cArqTrab)
#ENDIF	

If Len(aResumo)<=0
	AAdd(aResumo, Array(Len(aHeadRes)))
EndIf	

DEFINE MSDIALOG oDlgRes FROM 0,0 TO 365,600 TITLE cCadastro OF oMainWnd PIXEL
//DEFINE MSDIALOG oDlgRes FROM 0,0 TO 340,600 TITLE cCadastro OF oMainWnd PIXEL

oList:=TWBrowse():New(16,4,294,150,,aHeadRes,{100},oDlgRes,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
oList:SetArray(aResumo)
oList:bLine:={ || RetRes(oList:nAT) }
	
ACTIVATE MSDIALOG oDlgRes ON INIT EnchoiceBar(oDlgRes,{|| oDlgRes:End()},{|| oDlgRes:End()}) CENTERED	

RestArea(aArea)	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M110SLCITEM  ºAutor  ³Paulo Eduardo       º Data ³  06/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para montar array de itens da tela principal, com o     º±±
±±º          ³conteudo do SF3 de acordo com o tipo selecionado no Combobox   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M110SlcItem(oList,oCombo)
Local cArqTrab  := "",cCond := "",cChave:="",cQuery:="",cAliasSf3:=""
Local nOrdSF3   := 0,nCont := 1,nValor := 0,nMkd:=1,nContMkd:=0
Local aBaseTemp := {},aValTemp := {}
Local lCondIf   := .F.   
Local nI:=0, nA:=0, nX:=0
Local aArea := GetArea()
                   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta query para selecao dos itens a serem mostrados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

#IFDEF TOP
	cAliasSF3:="F3TMP"
	If Select(cAliasSF3)<>0
   		DbSelectArea(cAliasSF3)
   		DbCloseArea()
	Endif            
	
	cQuery := "SELECT * FROM "+RetSqlName("SF3")+" "+cAliasSF3+" "
    cQuery += "WHERE F3_FILIAL='"+ xFilial("SF3")+"'"+" AND RTRIM(F3_ESPECIE) = '"+ aTipos[1][oCombo:nAt]+"' "
    cQuery += "AND F3_TIPOMOV ='"+ IIf(mv_par01 == 1,'C','V') +"' AND "
    cQuery += "SUBSTRING(F3_ENTRADA,1,6) = '" + mv_par02+mv_par03 + "'"
	If !Empty(aTipos[3][oCombo:nAt])
		cQuery += " AND " + aTipos[3][oCombo:nAt]
    EndIf
    cQuery +=" AND D_E_L_E_T_<>'*' ORDER BY " 
	If cPaisLoc=="CHI"
		cQuery +="F3_NUMCOR,F3_ENTRADA,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_CFO" 
	Else
		cQuery +="F3_ENTRADA,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_CFO" 
	Endif
    cQuery :=ChangeQuery(cQuery)
	MsAguarde({|| dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSF3,.F.,.T.)},STR0024)
	For nX:=1 To Len(aHeader)
		If aHeader[nX][8] == "D"
			TCSetField(cAliasSF3,AllTrim(aHeader[nX][2]),"D",8,0)
		EndIf		                     
	Next
#ELSE
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta IndRegua para selecao do itens³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasSF3:="SF3"
	DbSelectArea(cAliasSF3)
	DbGoTop()         

	nOrdSF3 := IndexOrd()

	cCond := cAliasSF3+"->F3_FILIAL == '"+ xFilial(cAliasSF3) + "'.and. AllTrim("+cAliasSF3+"->F3_ESPECIE) == '"+ aTipos[1][oCombo:nAt]+"'"
	cCond += ".and. "+cAliasSF3+"->F3_TIPOMOV =='"+ IIf(mv_par01 == 1,'C','V') +"'.and."
	cCond += "SubStr(Dtos("+cAliasSF3+"->F3_ENTRADA),1,6) == '" + mv_par02+mv_par03 + "'"
	If !Empty(aTipos[3][oCombo:nAt])
		cCond += " .and. " + aTipos[3][oCombo:nAt]
 	EndIf
	cArqTrab := CriaTrab(Nil,.F.)
	If cPaisLoc=="CHI"
		cOrdem:="F3_NUMCOR+Dtos(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_CFO" 
	Else
		cOrdem:=SF3->(IndexKey())
	Endif
	IndRegua(cAliasSF3,cArqTrab,cOrdem,,cCond,STR0024)
#ENDIF

For nI:=1 To Len(aImpostos)               
	aImpostos[nI][3] := (cAliasSF3)->(FieldPos("F3_BASIMP"+aImpostos[nI][1]))
	aImpostos[nI][4] := (cALiasSF3)->(FieldPos("F3_VALIMP"+aImpostos[nI][1]))
Next          

DbSelectArea(cAliasSF3)
DbGoTop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta aItens de acordo com o aHeader, ou seja, sem os ³
//³campos de impostos                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            
For nA:=1 To Len(aCposDic)
	If aCposDic[nA][1] < 0
		nContMkd++
	EndIf
Next		

aItens := {}
While !(cAliasSF3)->(EOF())
	aAdd(aItens,Array(Len(aHeader)-nContMkd)) 
	cChave := (cAliasSf3)->F3_FILIAL+DTOS((cAliasSF3)->F3_ENTRADA)+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_CFO+(cAliasSF3)->F3_ESPECIE+(cAliasSF3)->F3_TIPOMOV
	nMkd := 1
	For nX:=1 To Len(aHeader)
		If aCposDic[nX][1] >= 0
			If aHeader[nMkd][10] <> "V"
			    aItens[Len(aItens)][nMkd]	:=	FieldGet(FieldPos(aHeader[nX][2]))
			Else                                                
				aItens[Len(aItens)][nMkd]	:=	CriaVar(aHeader[nX][2],.T.)
			Endif
			nMkd++
		EndIf	
	Next       
	aBaseTemp := {}
	aValTemp  := {}
	For nI :=1 To Len(aHeadBase)   
		If SubStr(aHeadBase[nI][2],10,Len(aHeadBase[nI][2])-9) $ cImpostos
			If aHeadBase[nI][10] <> "V"
				AAdd(aBaseTemp,FieldGet(FieldPos(aHeadBase[nI][2])))
			Else
				AAdd(aBaseTemp,CriaVar(aHeadBase[nI][2],.T.))
			Endif
		
			If aHeadVal[nI][10] <> "V"
				AAdd(aValTemp,FieldGet(FieldPos(aHeadVal[nI][2])))
			Else
				AAdd(aValTemp,CriaVar(aHeadVal[nI][2],.T.))
			Endif
		EndIf	
	Next

	(cAliasSF3)->(DbSkip())

	While (cAliasSF3)->F3_FILIAL+DTOS((cAliasSF3)->F3_ENTRADA)+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_CFO+;
		  (cAliasSF3)->F3_ESPECIE+(cAliasSF3)->F3_TIPOMOV == cChave 
		If aHeader[AScan(aHeader,{|x| x[2] = "F3_VALCONT"})][11] > 0
			aItens[Len(aItens)][aHeader[AScan(aHeader,{|x| x[2] = "F3_VALCONT"})][11]] += FieldGet(FieldPos("F3_VALCONT"))
		EndIf	                                                      
		If aHeader[AScan(aHeader,{|x| x[2] = "F3_VALMERC"})][11] > 0
		aItens[Len(aItens)][aHeader[AScan(aHeader,{|x| x[2] = "F3_VALMERC"})][11]] += FieldGet(FieldPos("F3_VALMERC"))
		EndIf
		If aHeader[AScan(aHeader,{|x| x[2] = "F3_OUTRAS"})][11] > 0
		aItens[Len(aItens)][aHeader[AScan(aHeader,{|x| x[2] = "F3_OUTRAS"})][11]]  += FieldGet(FieldPos("F3_OUTRAS"))
		EndIf
		If aHeader[AScan(aHeader,{|x| x[2] = "F3_FRETE"})][11] > 0
		aItens[Len(aItens)][aHeader[AScan(aHeader,{|x| x[2] = "F3_FRETE"})][11]]   += FieldGet(FieldPos("F3_FRETE"))  
		EndIf
		aItens[Len(aItens)][aHeader[AScan(aHeader,{|x| x[2] = "F3_EXENTAS"})][11]] += FieldGet(FieldPos("F3_EXENTAS"))
		For nI:=1 To Len(aImpostos)
			If aImpostos[nI][3] > 0 .and. aImpostos[nI][4] > 0
				aBaseTemp[nI] += FieldGet(aImpostos[nI][3])
				aValTemp[nI]  += FieldGet(aImpostos[nI][4])
			EndIf	
		Next  
		
		(cAliasSF3)->(DbSkip())
	EndDo	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona os campos de impostos obedecendo o parametro de³
	//³pergunta mv_par04 (agrupa outros impostos?)             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nValor := 0	
	If Len(aItens) > 0
		If mv_par04 > 1
			For nX:=1 To Len(aImpostos)
				AAdd(aItens[Len(aItens)],aBaseTemp[nX])
				AAdd(aItens[Len(aItens)],aValTemp[nX])
			Next
		Else
			AAdd(aItens[Len(aItens)],aBaseTemp[1])
			AAdd(aItens[Len(aItens)],aValTemp[1])
			If Len(aImpostos) > 1
				For nI:=2 To Len(aImpostos)
					nValor += aValTemp[nI]
				Next
				AAdd(aItens[Len(aItens)],nValor)
			EndIf	
		EndIf
	EndIf	
	
EndDo      

If Len(aItens) == 0
	aAdd(aItens,Array(Len(aHeadBrow)))
EndIf    

#IFDEF TOP
	DbSelectArea(cAliasSF3)
	DbCloseArea()
#ELSE
	RetIndex(cAliasSF3)
	(cAliasSF3)->(DbSetOrder(nOrdSF3))
	cArqTrab+=OrdBagExt()
	File(cArqTrab)
	Ferase(cArqTrab)
#ENDIF	

oList:SetArray(aItens)
oList:bLine:={ || RetLine(oList:nAT) }       
oList:Refresh()

lDic := .F.      

RestArea(aArea)
Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M110IMPLIVRO     º Autor ³ Paulo Eduardo      º Data ³  20/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para impressao do livro fiscal                             º±±
±±º          ³                                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function M110ImpLivro(oCombo)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1       := STR0025 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2       := STR0026 //"de acordo com os parametros informados pelo usuario."
Local cDesc3       := "MATC110"
Local cPict        := ""
Local titulo       := STR0027+IIf(mv_par01 == 1,STR0018,STR0019)+STR0039+MesExtenso(Val(mv_par03))+" / "+mv_par02  //"Livro de "##"Compras"##"Vendas"
Local nLin         := 80

Local Cabec1       := ""
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite           := 220
Private tamanho          := "G"
Private nomeprog         := "MATC110" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 18
Private aReturn          := { STR0028, 1, STR0029, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "MATC110" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := "SF3"
        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Header do relatorio             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ              
                                                                                          
Cabec1 := STR0030+Space(2)+STR0031+Space(8)+STR0020+Space(9)+STR0032+Space(2)+STR0033+Space(14)+; //"Esp."###"Data"###"Ser."###"Cliente/Fornecedor"
		Padr(AllTrim(RetTitle("A1_CGC")),14)+Space(17)+STR0022+Space(1)
Cabec1 += PadL(STR0014 + aImpostos[1][2],20," ") + Space(3)               
Cabec1 += PadL(STR0015 + aImpostos[1][2],20," ")
If Len(aImpostos) > 1
	Cabec1 += Space(3)+STR0016
	Cabec1 += Space(18)+STR0023
Else	
	Cabec1 += Space(19)+STR0023
EndIf	
If cPaisLoc == "CHI" .and. mv_par01 == 1
	Cabec1 += space(5)+STR0034 //"Correlativo"
EndIf	

wnrel := SetPrint(cString,NomeProg,,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| M110Imprime(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³M110IMPRIME º Autor ³ Paulo Eduardo      º Data ³  20/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS   º±±
±±º          ³ monta a janela com a regua de processamento.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function M110Imprime(Cabec1,Cabec2,Titulo,nLin)
Local aArea := GetArea()

#IFDEF TOP
	Local cLoja	 := ""
	Local cQuery := ""
	Local nOrdem := 1
	Local nX
#ENDIF

Local nI := 0
Local nOrdSF3 :=1
Local cCliLivro  := ""
Local cCGC       := ""
Local cCliFor    := ""
Local dDataEnt
Local cNFiscal   := ""
Local cSerie     := "" 
Local nF
Local cCorrel	 := ""
Local cEspecie   := ""               
Local cTipo		 := ""
Local cCond 	 := "", cAliasSF3 := "", cArqTrab := ""
Local lFirstImp	 := .T.
Local nIsento 	 := 0, nMainBase:= 0, nMainImp := 0, nOutImp := 0, nTotLin := 0                       
Local nTotLinha:= 0, nTotOutros:=0, nTotImp := 0,nTotIsento:=0,nTotBase :=0
Local nGerLinha:= 0, nGerOutros:=0, nGerImp := 0,nGerIsento:=0,nTotBs:=0
Local cbcont:=0,cbtxt:=space(10),nPosCorr:=0
Local aAreaSF

#IFDEF TOP
	cAliasSF3:="F3TMP"
	If Select(cAliasSF3)<>0
   		DbSelectArea(cAliasSF3)
   		DbCloseArea()
	Endif            

	cQuery := "SELECT * FROM "+RetSqlName("SF3")+" "+cAliasSF3+" "
    cQuery += "WHERE F3_FILIAL='"+ xFilial("SF3")+"' "
    cQuery += "AND F3_TIPOMOV ='"+ IIf(mv_par01 == 1,'C','V') +"'AND "
    cQuery += "SUBSTRING(F3_ENTRADA,1,6) = '" + mv_par02+mv_par03 + "'"
    cQuery += " AND RTRIM(F3_ESPECIE) IN ("
    For nI := 1 To Len(aTipos[1])
    	If nI > 1
    		cQuery += ","
    	Endif
    	cQuery += "'" + AllTrim(aTipos[1][nI]) + "'"
    Next
    cQuery += ") "
    cQuery +=" AND D_E_L_E_T_<>'*' ORDER BY " 
    cQuery +="F3_ESPECIE,F3_ENTRADA,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_CFO" 
    cQuery :=ChangeQuery(cQuery)
	MsAguarde({|| dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSF3,.F.,.T.)},STR0024)
	For nI:=1 To Len(aHeader)
		If aHeader[nI][8] == "D"
			TCSetField(cAliasSF3,AllTrim(aHeader[nI][2]),"D",8,0)
		EndIf		                     
	Next
#ELSE
	cAliasSF3:="SF3"
	DbSelectArea(cAliasSF3)
	DbGoTop()         

	nOrdSF3 := IndexOrd()
            
	cCond := cAliasSF3+"->F3_FILIAL == '"+ xFilial(cAliasSF3) + "' "
	cCond += ".and. "+cAliasSF3+"->F3_TIPOMOV =='"+ IIf(mv_par01 == 1,'C','V') +"'.and."
	cCond += "SubStr(Dtos("+cAliasSF3+"->F3_ENTRADA),1,6) == '" + mv_par02+mv_par03 + "'"
	cCond += " .and. Alltrim(" + cAliasSF3 + "->F3_ESPECIE) $ '"
	For nI := 1 To Len(aTipos[1])
		cCond += "|" + AllTrim(aTipos[1][nI])
	Next
	cCond += "'"
	cArqTrab := CriaTrab(Nil,.F.)
	IndRegua(cAliasSF3,cArqTrab,"F3_ESPECIE+DTOS(F3_ENTRADA)+F3_NFISCAL+substr(F3_SERIE,1,3)+F3_CLIEFOR+F3_LOJA+F3_CFO",,cCond,STR0024) //"Selecionando Facturas" //Alterado Tiago Silva, PRJ Chave Unica
#ENDIF
If !(cAliasSF3)->(EOF())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetRegua(RecCount())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca dados referentes ao cliente³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While !(cAliasSF3)->(EOF())
		cChave := (cAliasSf3)->F3_FILIAL+DTOS((cAliasSF3)->F3_ENTRADA)+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+; 
					(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_CFO+(cAliasSF3)->F3_ESPECIE+(cAliasSF3)->F3_TIPOMOV
		cEspecie  := (cAliasSF3)->F3_ESPECIE			
		cTipo     := (cAliasSF3)->F3_TIPO
		cCliLivro := (cAliasSF3)->F3_CLIEFOR + (cAliasSF3)->F3_LOJA
		dDataEnt  := (cAliasSF3)->F3_ENTRADA
		cNFiscal  := (cAliasSF3)->F3_NFISCAL
		cSerie    := (cAliasSF3)->F3_SERIE 
		nIsento   := (cAliasSF3)->F3_EXENTAS 
		
		nMainBase :=  0 
		
       If (cAliasSF3)->F3_BASIMP1 > 0
	       nMainBase := (cAliasSF3)->F3_BASIMP1
       ElseIf (cAliasSF3)->F3_BASIMP2 > 0
           nMainBase := (cAliasSF3)->F3_BASIMP2
       ElseIf (cAliasSF3)->F3_BASIMP3 > 0
           nMainBase := (cAliasSF3)->F3_BASIMP3
       ElseIf (cAliasSF3)->F3_BASIMP4 > 0
	       nMainBase := (cAliasSF3)->F3_BASIMP4
       ElseIf (cAliasSF3)->F3_BASIMP5 > 0
	       nMainBase := (cAliasSF3)->F3_BASIMP5
       ElseIf (cAliasSF3)->F3_BASIMP6 > 0
           nMainBase := (cAliasSF3)->F3_BASIMP6
	   EndIf   	   
       nMainImp := (cAliasSF3)->F3_VALIMP1	   	         
		nTotLin   := (cAliasSF3)->F3_VALMERC
		nOutImp   := 0		
		nAbatImp	:=0         
		If Len(aImpostos) > 1
			For nF:=2 To Len(aImpostos)
				If cPaisLoc == "PER"  .And. "DIG" $ Alltrim(aImpostos[nF][2])
					nAbatImp	:= nAbatImp+	FieldGet(aImpostos[nF][4])
	            EndIF
       		    nOutImp   += FieldGet(aImpostos[nF][4]) 	
		    Next
		EndIf	
					    
		If Len(cCliLivro) > 0  
			If mv_par01 == 1 //Compras
				If (cAliasSf3)->F3_TIPO <> "B"
					SA2->(DbGoTop())
					If SA2->(MsSeek(xFilial()+cCliLivro))
						cCliFor := TransForm(SubStr(SA2->A2_NOME,1,30),PesqPict("SA2","A2_NOME"))
						cCGC    := TransForm(SA2->A2_CGC,PesqPict("SA2","A2_CGC"))
					Else 
						cCliFor := SubStr(cCliLivro,1,30)
						cCGC    := TransForm("",PesqPict("SA2","A2_CGC"))
					EndIf
				Else                
					SA1->(DbGoTop())
					If SA1->(MsSeek(xFilial()+cCliLivro))
						cCliFor := TransForm(SubStr(SA1->A1_NOME,1,30),PesqPict("SA1","A1_NOME"))
						cCGC    := TransForm(SA1->A1_CGC,PesqPict("SA1","A1_CGC"))
					Else 
						cCliFor := SubStr(cCliLivro,1,30)
						cCGC    := TransForm("",PesqPict("SA1","A1_CGC"))
					EndIf
				EndIf	
			Else        //Vendas
				If (cAliasSf3)->F3_TIPO <> "B"
					SA1->(DbGoTop())
					If SA1->(MsSeek(xFilial()+cCliLivro))
						cCliFor := TransForm(SubStr(SA1->A1_NOME,1,30),PesqPict("SA1","A1_NOME"))
						cCGC    := TransForm(SA1->A1_CGC,PesqPict("SA1","A1_CGC"))
					Else 
						cCliFor := SubStr(cCliLivro,1,30)
						cCGC    := TransForm("",PesqPict("SA1","A1_CGC"))
					EndIf
				Else                
					SA2->(DbGoTop())
					If SA2->(MsSeek(xFilial()+cCliLivro))
						cCliFor := TransForm(SubStr(SA2->A2_NOME,1,30),PesqPict("SA2","A2_NOME"))
						cCGC    := TransForm(SA2->A2_CGC,PesqPict("SA2","A2_CGC"))
					Else 
						cCliFor := SubStr(cCliLivro,1,30)
						cCGC    := TransForm("",PesqPict("SA2","A2_CGC"))
					EndIf
				EndIf	
			EndIf	
		EndIf
		       
		If cPaisLoc == "CHI" .and. mv_par01 == 1 
		   	nPosCorr:= FieldPos("F3_NUMCOR")
		   	cCorrel := FieldGet(nPosCorr)
		EndIf	

		If cPaisLoc <> "BRA"		
			aAreaSF := GetArea()
			If (cAliasSF3)->F3_TIPOMOV == "V"
				dbSelectArea("SF2")
				SF2->(dbSetOrder(1))
				SF2->(dbGoTop())
				If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)) 
					nTotLin += Round(xMoeda(SF2->F2_SEGURO+SF2->F2_FRETE+SF2->F2_DESPESA,SF2->F2_MOEDA,1,,5,SF2->F2_TXMOEDA),MsDecimais(1))
				EndIf
			Else
				dbSelectArea("SF1")
				SF1->(dbSetOrder(1))
				SF1->(dbGoTop())
				If SF1->(dbSeek(xFilial("SF1")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
					nTotLin += Round(xMoeda(SF1->F1_SEGURO+SF1->F1_FRETE+SF1->F1_DESPESA,SF1->F1_MOEDA,1,,5,SF1->F1_TXMOEDA),MsDecimais(1))
				EndIf
			EndIf
			RestArea(aAreaSF)
		EndIf
		(cAliasSf3)->(DbSkip())
		
		While (cAliasSf3)->F3_FILIAL+DTOS((cAliasSF3)->F3_ENTRADA)+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+; 
			(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_CFO+(cAliasSF3)->F3_ESPECIE+;
			(cAliasSF3)->F3_TIPOMOV == cChave
			nIsento   += (cAliasSF3)->F3_EXENTAS 
            nMainBase += (cAliasSF3)->F3_BASIMP1
			nMainImp  += (cAliasSF3)->F3_VALIMP1
			nTotLin   += (cAliasSF3)->F3_VALMERC
		
			If Len(aImpostos) > 1
				For nF:=2 To Len(aImpostos)
					nOutImp   += FieldGet(aImpostos[nF][4])
		    		If cPaisLoc == "PER"  .And. "DIG" $ Alltrim(aImpostos[nF][2])
						nAbatImp	:= nAbatImp+	FieldGet(aImpostos[nF][4])
		            EndIF
		    	Next
			EndIf		
			(cAliasSF3)->(DbSkip())
		EndDo
             
		If Len(aImpostos) > 1
			nTotLin += nMainImp - nAbatImp + nOutImp 
		Else			
			nTotLin += nMainImp				
		EndIf   
					
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Alimenta acumuladores de totais por especie³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTotIsento += nIsento
		nTotImp    += nMainImp
		nTotBase   += nMainBase
		If Len(aImpostos) > 1
			nTotOutros += nOutImp
			nTotLinha  += nTotLin
		Else         
			nTotLinha  += nTotalLin
		EndIf	                                       
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Alimenta acumuladores de totais Gerais     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTipo <> "D"
			nGerIsento += nIsento
			nGerImp    += nMainImp
			nTotBs     += nMainBase
			If Len(aImpostos) > 1
				nGerOutros += nOutImp
				nGerLinha  += nTotLin
			Else         
				nGerLinha  += nTotLin
			EndIf
		Else                     
			nGerIsento -= nIsento
			nGerImp    -= nMainImp
			nTotBs     -= nMainBase			
			If Len(aImpostos) > 1
				nGerOutros -= nOutImp
				nGerLinha  -= nTotLin
			Else         
				nGerLinha  -= nTotLin
			EndIf
		EndIf		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAbortPrint
			@nLin,00 PSAY STR0040
    		Exit
		Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do cabecalho do relatorio. . .                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If nLin > 58 // Salto de Página. Neste caso o formulario tem 55 linhas...
   			nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
   			nLin ++
		Endif
    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime os registros³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFirstImp
				@nLin,00  PSAY "********** "+aTipos[2][AScan(aTipos[1],AllTrim(cEspecie))]+" **********"
			nLin++                                
			lFirstImp := .F.
		EndIf	
	
		@nLin,00  PSAY IIf(nTotLin <> 0,AllTrim(cEspecie),"")
		@nLin,06  PSAY Padr(dDataEnt,10)
		@nLin,16  PSAY cNFiscal
		@nLin,37  PSAY Transform(cSerie,PesqPict("SF3","F3_SERIE")) //Alterado por Tiago Silva, PRJ Chave Unica
		@nLin,43  PSAY cCliFor
		@nLin,74  PSAY cCGC 
		If cTipo <> "D"
			@nLin,93  PSAY Transform(nIsento,PesqPict("SF3","F3_EXENTAS"))	
			@nLin,114 PSAY Transform(nMainBase,PesqPict("SF3","F3_BASIMP1"))	
			@nLin,137 PSAY Transform(nMainImp,PesqPict("SF3","F3_VALIMP1"))	
			If Len(aImpostos) > 1
				@nLin,161 PSAY Transform(nOutImp,PesqPict("SF3","F3_VALIMP1"))	
				@nLin,184 PSAY Transform(nTotLin,PesqPict("SF3","F3_VALMERC"))	//-> F3_VALMERC
			Else
				@nLin,161 PSAY Transform(nTotLin,PesqPict("SF3","F3_VALMERC"))	//-> F3_VALMERC
			EndIf	
		Else	
			@nLin,93  PSAY Transform(nIsento *-1,PesqPict("SF3","F3_EXENTAS"))	
			@nLin,114 PSAY Transform(nMainBase *-1,PesqPict("SF3","F3_BASIMP1"))	
			@nLin,137 PSAY Transform(nMainImp *-1,PesqPict("SF3","F3_VALIMP1"))	
			If Len(aImpostos) > 1
				@nLin,161 PSAY Transform(nOutImp *-1,PesqPict("SF3","F3_VALIMP1"))	
				@nLin,184 PSAY Transform(nTotLin *-1,PesqPict("SF3","F3_VALMERC"))	//-> F3_VALMERC
			Else
				@nLin,161 PSAY Transform(nTotLin *-1,PesqPict("SF3","F3_VALMERC"))	//-> F3_VALMERC
			EndIf	
		EndIf	
					
		If cPaisLoc == "CHI" .and. mv_par01 == 1
		   	@nLin,207 PSAY cCorrel
		EndIf	
		nLin := nLin + 1 
		IncRegua()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime a totalizacao para cada especie de documento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		If (cAliasSf3)->F3_ESPECIE <> cEspecie 
			@nLin,00  PSAY STR0023 +" "+cEspecie
			If cTipo <> "D"
				@nLin,93  PSAY Transform(nTotIsento,PesqPict("SF3","F3_VALIMP1"))                   
				@nLin,114 PSAY Transform(nTotBase,PesqPict("SF3","F3_BASIMP1"))										
				@nLin,137 PSAY Transform(nTotImp,PesqPict("SF3","F3_VALIMP1"))
				If Len(aImpostos) > 1
					@nLin,161 PSAY Transform(nTotOutros,PesqPict("SF3","F3_VALIMP1"))
					@nLin,184 PSAY Transform(nTotLinha,PesqPict("SF3","F3_VALIMP1"))
				Else
					@nLin,161 PSAY Transform(nTotLinha,PesqPict("SF3","F3_VALIMP1"))
				EndIf          
			Else
				@nLin,93  PSAY Transform(nTotIsento *-1,PesqPict("SF3","F3_VALIMP1"))
				@nLin,114 PSAY Transform(nTotBase,PesqPict("SF3","F3_BASIMP1"))						
				@nLin,137 PSAY Transform(nTotImp *-1,PesqPict("SF3","F3_VALIMP1"))
				If Len(aImpostos) > 1
					@nLin,161 PSAY Transform(nTotOutros *-1,PesqPict("SF3","F3_VALIMP1"))
					@nLin,184 PSAY Transform(nTotLinha *-1,PesqPict("SF3","F3_VALIMP1"))
				Else
					@nLin,161 PSAY Transform(nTotLinha *-1,PesqPict("SF3","F3_VALIMP1"))
				EndIf          
			EndIf
				
			If (cAliasSF3)->(!EOF())
				cEspecie := (cAliasSf3)->F3_ESPECIE
				nLin += 2
				@nLin,00  PSAY "********** "+aTipos[2][AScan(aTipos[1],AllTrim(cEspecie))]+" **********"
				nLin++
			EndIf	
			
			nTotIsento := 0
			nTotImp    := 0
			nTotOutros := 0
			nTotLinha  := 0
			nTotBase   := 0
		EndIf	
	EndDo
			                                                      
	@nLin+2,00  PSAY STR0043
	@nLin+2,93  PSAY Transform(nGerIsento,PesqPict("SF3","F3_VALIMP1")) 
	@nLin+2,114 PSAY Transform(nTotBs,PesqPict("SF3","F3_BASIMP1"))		
	@nLin+2,137 PSAY Transform(nGerImp,PesqPict("SF3","F3_VALIMP1"))
	If Len(aImpostos) > 1
		@nLin+2,161 PSAY Transform(nGerOutros,PesqPict("SF3","F3_VALIMP1"))
		@nLin+2,184 PSAY Transform(nGerLinha,PesqPict("SF3","F3_VALIMP1"))
	Else
		@nLin+2,161 PSAY Transform(nGerLinha,PesqPict("SF3","F3_VALIMP1"))
	EndIf		                            
		
	roda(cbcont,cbtxt,"G")
		    
	#IFDEF TOP                                              
		DbSelectArea(cAliasSF3)
		DbCloseArea()
	#ELSE	
		RetIndex(cAliasSF3)
		(cAliasSF3)->(DbSetOrder(nOrdSF3))
		cArqTrab+=OrdBagExt()
		File(cArqTrab)
		Ferase(cArqTrab)
	#ENDIF		
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M110DIC   ºAutor  ³Paulo Eduardo       º Data ³  07/16/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para criacao da janela de dicionario                 º±±
±±º          ³cObjeto := Alias do arquivo de onde serao apresentados os   º±±
±±º          ³           campos para selecao                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function M110Dic(cObjeto)
Local aLinObj :={3,15,27,39,51,63}
Local aLeftObj:={2,45,180,225}
Local cCondMarca := ""
Local oPanDic
Local nI := 0
Local aAux :={},aMkdCpos:={}
Local cCamposObj := ""
Local nPosCampo := 0
Local lCancel := .F.
Private cAlias := cObjeto
Private cClasseFilho:= ""
Private oListCpos
Private oOk     := LoadBitMap(GetResources(), "LBOK")        	// Bitmap utilizado no Lisbox  (Marcado)
Private oNo     := LoadBitMap(GetResources(), "LBNO")			// Bitmap utilizado no Lisbox  (Desmarcado)
Private oNever  := LoadBitMap(GetResources(), "DISABLE")		// Bitmap utilizado no Lisbox  (Desabilitado)
                     
For nI:=1 To Len(aCposDic)
	AAdd(aMkdCpos,aCposDic[nI][1])
Next	

DEFINE MSDIALOG oDlgDic TITLE FunDesc() FROM 0,0 TO 285,620 PIXEL OF oMainWnd VBX

oPanDic:= TPanel():New(013,000,,oDlgDic,,,,,,oDlgDic:nWidth,oDlgDic:nHeight-013,.F.,.F.)

@ aLinObj[1],aLeftObj[1] SAY STR0035 Size 40,18  Pixel Of oPanDic //"Arquivo"
//@ aLinObj[1]  ,aLeftObj[2] MSGET cAlias  Picture "@!"  Size 15,10  Valid (cAlias==cObjeto .Or. LstCpos(cAlias,@oListCpos,'oListCpos')) Pixel Of oPanDic
@ aLinObj[1]  ,aLeftObj[2] MSGET cAlias  Picture "@!"  Size 15,10  When .F. Pixel Of oPanDic

aAux:=LocxHead("SX3",.T.,,{"X3_GRUPO","X3_USADO"},,,.F.)
oListCpos := TwBrowse():New(017,002,305,110,,{"",STR0036,STR0037},,oPanDic,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Campo"###"Descricao"
oListCpos:SetArray(aCposDic)       
oListCpos:bLine:={ || {If(oListCpos:aArray[oListCpos:nAt,1]>0,oOk,If(oListCpos:aArray[oListCpos:nAt,1]<0,oNo,oNever)),aCposDic[oListCpos:nAT,2],aCposDic[oListCpos:nAT,3]} }
oListCpos:bLDblClick:= {|| (oListCpos:aArray[oListCpos:nAt][1]:=oListCpos:aArray[oListCpos:nAt][1]*-1)}

ACTIVATE MSDIALOG oDlgDic ON INIT (EnchoiceBar(oDlgDic,{|| lDic:=.T.,oDlgDic:End(),lContCons:=.T.,oDlg:End()},{|| lCancel:=.T.,oDlgDic:End()},,)) CENTERED

If lCancel
	For nI:=1 To Len(aCposDic)
		aCposDic[nI][1] := aMkdCpos[nI]
	Next
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RETLINE   ºAutor  ³Paulo Eduardo       º Data ³  07/18/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para ser executada no Bline.                         º±±
±±º          ³Retorna array contendo a linha atual do aItens              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RetLine(nPosLine)                                  
Local nX :=1, nI:=0
Local nQtdImp := 0
Local aLine   := {}                

If mv_par04 > 1
	nQtdImp := Len(aImpostos)*2
Else
	If Len(aImpostos) > 1
		nQtdImp := 3
	Else
		nQtdImp := 2
	EndIf		
EndIf	         

For nX:=1 To Len(aHeadBrow)-nQtdImp
	If aItens[nPosLine][nX] <> Nil
	 If AllTrim(aHeader[AScan(aHeader,{|x| x[11] == nX})][2]) == "F3_EXENTAS"
 			AAdd(aLine,Transform(aItens[nPosLine][nX],aHeadVal[AScan(aHeadVal,{|x| AllTrim(x[2]) == "F3_VALIMP1"})][3]))
		Else	
			AAdd(aLine,Transform(aItens[nPosLine][nX],aHeader[AScan(aHeader,{|x| x[11] == nX})][3]))
	  	EndIf	    
	Else
		AAdd(aLine,Nil)
	EndIf	
Next  

For nI:=nX To Len(aHeadBrow)    
	If aItens[nPosLine][nI] <> Nil
		AAdd(aLine,Transform(aItens[nPosLine][nI],aHeadVal[AScan(aHeadVal,{|x| AllTrim(x[2]) == "F3_VALIMP1"})][3]))
	Else
		AAdd(aLine,Nil)
	EndIf	
Next

Return aLine

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RETRES    ºAutor  ³Paulo Eduardo       º Data ³  07/18/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para ser executada no Bline.                         º±±
±±º          ³Retorna array contendo a linha atual do aResumo             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RetRes(nPosLine)                                  
Local nX :=1
Local aLine   := {}                

AAdd(aLine,aResumo[nPosLine][1])
AAdd(aLine,aResumo[nPosLine][2])

For nX:=3 To Len(aHeadRes)
	If aResumo[nPosLine][nX] <> Nil
		AAdd(aLine,Transform(aResumo[nPosLine][nX],PesqPict("SF3","F3_VALIMP1")))
	Else
		AAdd(aLine,Nil)
	EndIf	
Next  

Return aLine
