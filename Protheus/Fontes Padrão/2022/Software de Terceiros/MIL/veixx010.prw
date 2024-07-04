// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 18     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#Include "VEIXX010.CH"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  25/10/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007322_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VEIXX010 º Autor ³ Andre Luis Almeida º Data ³  19/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Consorcio                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nOpc (2-Visualizar/4-Alterar/3-Incluir)                    º±±
±±º          ³ aParCon (Parametros do Consorcio)                          º±±
±±º			 ³	 aParCon[1] Nro do Atendimento                            º±±
±±º          ³ aVS9 (Pagamentos)                                          º±±
±±º			 ³	 aVS9[1] aHeader VS9                                      º±±
±±º          ³   aVS9[2] aCols VS9                                        º±±
±±º          ³ aVSE (Observacoes Pagamento)                               º±±
±±º			 ³	 aVSE[1] aHeader VSE                                      º±±
±±º          ³   aVSE[2] aCols VSE                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos -> Novo Atendimento                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXX010(nOpc,aParCon,aVS9,aVSE)
Local aObjects  := {} , aPos := {} , aInfo := {} 
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local lRet      := .f.
Local nCntFor   := 1
Local nx        := 0
Local ni        := 0
Local nj        := 0
Local nk        := 0
Local nPos      := 0
Local nOpcao    := 0
Local cSEQUEN   := ""
Local cQuery    := ""
Local cQAlias   := "SQLALIAS"
Local cAux      := ""
Local lTemFinan := .f.
Local lTemFname := .f.
Local cTpPagFin := ""
Local cTpFiname := FM_SQL("SELECT VSA.VSA_TIPPAG FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPO='6' AND VSA.D_E_L_E_T_=' '") // VSA_TIPO='6' ( Finame )
Local cTpPagCon := FM_SQL("SELECT VSA.VSA_TIPPAG FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPO='3' AND VSA.D_E_L_E_T_=' '") // VSA_TIPO='3' ( Consorcio )
Private	aConsorcio := {{ctod(""),0,"0","","","",0}}
Private aHeaderVS9 := aClone(aVS9[1])
Private aHeaderVSE := aClone(aVSE[1])
If !Empty(aParCon[1])
	DbSelectArea("VV9")
	DbSetOrder(1)
	DbSeek(xFilial("VV9")+aParCon[1])
	DbSelectArea("VV0")
	DbSetOrder(1)
	DbSeek(xFilial("VV0")+aParCon[1])
EndIf
// Fator de reducao 80%
For nCntFor := 1 to Len(aSizeHalf)
	aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.8)
Next   
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 0, 18, .T. , .F. } ) // Botoes
AAdd( aObjects, { 0,  0, .T. , .T. } ) // Consorcio
aPos := MsObjSize( aInfo, aObjects )
aVSE[2] := {}
If nOpc == 3 .or. nOpc == 4 // Incluir / Alterar
	If Empty(cTpPagCon)
		MsgStop(STR0006,STR0005) // Impossivel continuar! Nao existe Tipo de Pagamento relacionado a Consorcio. / Atencao
		Return lRet
	EndIf
EndIf
// Levanta todos os Tipos de Pagamento para Financiamento / Leasing  ( VSA_TIPO='1' )
cQuery := "SELECT VSA.VSA_TIPPAG FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPO='1' AND VSA.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. ) 
Do While !( cQAlias )->( Eof() )
	cTpPagFin += Alltrim(( cQAlias )->( VSA_TIPPAG ))+"/"
  	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() ) 
aConsorcio := {}
For ni := 1 to len(aVS9[2]) // Selecionar os Consorcios ja utilizados neste Atendimento
	If !aVS9[2,ni,len(aVS9[2,ni])] .and. !Empty(aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")])
		If !Empty(cTpPagCon)
			If aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")] == cTpPagCon
				aAdd(aConsorcio,{aVS9[2,ni,FG_POSVAR("VS9_DATPAG","aHeaderVS9")],aVS9[2,ni,FG_POSVAR("VS9_VALPAG","aHeaderVS9")],left(aVS9[2,ni,FG_POSVAR("VS9_REFPAG","aHeaderVS9")],1),"","","",ni})
				cAux := aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")]+aVS9[2,ni,FG_POSVAR("VS9_SEQUEN","aHeaderVS9")]
				// Trazer Observacoes do VSE //
				nPos := 3
		        For nj := 1 to len(aVSETotal[2])
					If !aVSETotal[2,nj,len(aVSETotal[2,nj])]
			    		If aVSETotal[2,nj,FG_POSVAR("VSE_TIPPAG","aHeaderVSE")] + aVSETotal[2,nj,FG_POSVAR("VSE_SEQUEN","aHeaderVSE")] == cAux
							nPos++
							aConsorcio[len(aConsorcio),nPos] := aVSETotal[2,nj,FG_POSVAR("VSE_VALDIG","aHeaderVSE")]
							If nPos == 6
								Exit
							EndIf
			        	EndIf
		        	EndIf
				Next
				///////////////////////////////
	           	aAdd(aVSE[2],Array(len(aVSE[1])+1))
    	       	nPos := len(aVSE[2])
        	   	aVSE[2,nPos,FG_POSVAR("VSE_NUMIDE","aHeaderVSE")] := aVS9[2,ni,FG_POSVAR("VS9_NUMIDE","aHeaderVS9")]
				aVSE[2,nPos,FG_POSVAR("VSE_TIPOPE","aHeaderVSE")] := aVS9[2,ni,FG_POSVAR("VS9_TIPOPE","aHeaderVS9")]
				aVSE[2,nPos,FG_POSVAR("VSE_TIPPAG","aHeaderVSE")] := aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")]
				aVSE[2,nPos,FG_POSVAR("VSE_SEQUEN","aHeaderVSE")] := aVS9[2,ni,FG_POSVAR("VS9_SEQUEN","aHeaderVS9")]
				aVSE[2,nPos,len(aVSE[2,nPos])] := .t.
			EndIf
		EndIf
		If !Empty(aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")])
			If !Empty(cTpPagFin) // Verifica se ja existe Financiamento para o Atendimento
				If (Alltrim(aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")])+"/") $ cTpPagFin
					lTemFinan := .t.
				EndIf
			EndIf
			If !Empty(cTpFiname) // Verifica se ja existe Finame para o Atendimento
				If aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")] == cTpFiname
					lTemFname := .t.
				EndIf
			EndIf
		EndIf
	EndIf
Next
If len(aConsorcio) <= 0
	aConsorcio := {{ctod(""),0,"0","","","",0}}
EndIf
DbSelectArea("VS9")
DEFINE MSDIALOG oTelaCon TITLE STR0001 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // Consorcio
	oTelaCon:lEscClose := .F.
	@ aPos[2,1],aPos[2,2] LISTBOX oLboxCon FIELDS HEADER STR0007,STR0008,STR0009,STR0010,STR0011,STR0012 COLSIZES 30,40,40,100,40,40 SIZE aPos[2,4],aPos[2,3]-aPos[2,1] OF oTelaCon PIXEL ON DBLCLICK IIf(( nOpc == 3 .or. nOpc == 4 ),FS_INCALT("A",oLboxCon:nAt,lTemFinan,lTemFname,aVS9,cTpPagCon),.t.) // Data / Valor / Quitado / Administradora / Grupo / Cota
	oLboxCon:SetArray(aConsorcio)
	oLboxCon:bLine := { || { Transform(aConsorcio[oLboxCon:nAt,1],"@D"),;
							FG_AlinVlrs(Transform(aConsorcio[oLboxCon:nAt,02],"@E 9,999,999.99")),;
							IIf(aConsorcio[oLboxCon:nAt,03]=="1",STR0013,STR0014),; // Sim / Nao
							IIf(!Empty(aConsorcio[oLboxCon:nAt,04]),Alltrim(aConsorcio[oLboxCon:nAt,04])+" - "+POSICIONE("VV4",1,xFilial("VV4")+Alltrim(aConsorcio[oLboxCon:nAt,04]),"VV4_DESCRI"),""),;
							aConsorcio[oLboxCon:nAt,05],;
							aConsorcio[oLboxCon:nAt,06]}}
	DEFINE SBUTTON FROM aPos[1,1]+006,005 TYPE  4 ACTION FS_INCALT("I",oLboxCon:nAt,lTemFinan,lTemFname,aVS9,cTpPagCon) ENABLE ONSTOP STR0002 OF oTelaCon WHEN ( nOpc == 3 .or. nOpc == 4 ) // Incluir
	DEFINE SBUTTON FROM aPos[1,1]+006,035 TYPE 11 ACTION FS_INCALT("A",oLboxCon:nAt,lTemFinan,lTemFname,aVS9,cTpPagCon) ENABLE ONSTOP STR0003 OF oTelaCon WHEN ( nOpc == 3 .or. nOpc == 4 ) // Editar
	DEFINE SBUTTON FROM aPos[1,1]+006,065 TYPE  3 ACTION FS_INCALT("E",oLboxCon:nAt,lTemFinan,lTemFname,aVS9,cTpPagCon) ENABLE ONSTOP STR0004 OF oTelaCon WHEN ( nOpc == 3 .or. nOpc == 4 ) // Excluir
ACTIVATE MSDIALOG oTelaCon CENTER ON INIT (EnchoiceBar(oTelaCon,{|| nOpcao:=1 , oTelaCon:End()},{ || oTelaCon:End()},,))
If nOpcao == 1 // OK Tela
	If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
		lRet := .t.
		For ni := 1 to len(aVS9[2]) // Deletar todos os registros relacionados aos Consorcios utilizados neste Atendimento
			If aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")] == cTpPagCon
				If !aVS9[2,ni,len(aVS9[2,ni])]
					aVS9[2,ni,len(aVS9[2,ni])] := .t. // Deletar aCols do VS9
                EndIf
	            cSEQUEN += aVS9[2,ni,FG_POSVAR("VS9_SEQUEN","aHeaderVS9")]+"/"
     		EndIf
     	Next
		nj := 0
     	For ni := 1 to len(aConsorcio)
    		If !Empty(aConsorcio[ni,1])
                If aConsorcio[ni,7] > 0 // Reutiliza registro do VS9
					nPos := aConsorcio[ni,7]
					nj := val(aVS9[2,nPos,FG_POSVAR("VS9_SEQUEN","aHeaderVS9")])
				Else // Inclui na aCols do VS9
		           	aAdd(aVS9[2],Array(len(aVS9[1])+1)) 
		           	nPos := len(aVS9[2])
		           	nj := 0
		    	EndIf
		    	If nj == 0
					While .t.
			           	nj++
						If !( strzero(nj,2) $ cSEQUEN )
							cSEQUEN += strzero(nj,2)+"/"
							Exit
						EndIf
					EndDo
				EndIf
				aVS9[2,nPos,FG_POSVAR("VS9_NUMIDE","aHeaderVS9")] := PadR(aParCon[1],aVS9[1,FG_POSVAR("VS9_NUMIDE","aHeaderVS9"),4]," ") // Nro do Atendimento
				aVS9[2,nPos,FG_POSVAR("VS9_TIPOPE","aHeaderVS9")] := "V" // Veiculos
				aVS9[2,nPos,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")] := cTpPagCon
				aVS9[2,nPos,FG_POSVAR("VS9_DATPAG","aHeaderVS9")] := aConsorcio[ni,1]
				aVS9[2,nPos,FG_POSVAR("VS9_VALPAG","aHeaderVS9")] := aConsorcio[ni,2]
				aVS9[2,nPos,FG_POSVAR("VS9_REFPAG","aHeaderVS9")] := aConsorcio[ni,3]
				aVS9[2,nPos,FG_POSVAR("VS9_SEQUEN","aHeaderVS9")] := strzero(nj,2)
				aVS9[2,nPos,len(aVS9[2,nPos])] := .f.
				nx := len(aVSE[2])
				For nk := (nx+1) to (nx+3)
		           	aAdd(aVSE[2],Array(len(aVSE[1])+1))
					aVSE[2,nk,FG_POSVAR("VSE_NUMIDE","aHeaderVSE")] := aParCon[1] // Nro do Atendimento
					aVSE[2,nk,FG_POSVAR("VSE_TIPOPE","aHeaderVSE")] := "V"
					aVSE[2,nk,FG_POSVAR("VSE_TIPPAG","aHeaderVSE")] := cTpPagCon
					Do Case
						Case nk == (nx+1) // Administradora
							aVSE[2,nk,FG_POSVAR("VSE_DESCCP","aHeaderVSE")] := "1"+STR0015+":" // Adm.
							aVSE[2,nk,FG_POSVAR("VSE_NOMECP","aHeaderVSE")] := "ADMCON"
							aVSE[2,nk,FG_POSVAR("VSE_VALDIG","aHeaderVSE")] := aConsorcio[ni,4]
						Case nk == (nx+2) // Grupo
							aVSE[2,nk,FG_POSVAR("VSE_DESCCP","aHeaderVSE")] := "2"+STR0011+":" // Grupo
							aVSE[2,nk,FG_POSVAR("VSE_NOMECP","aHeaderVSE")] := "GRUCON"
							aVSE[2,nk,FG_POSVAR("VSE_VALDIG","aHeaderVSE")] := aConsorcio[ni,5]
						Case nk == (nx+3) // Cota
							aVSE[2,nk,FG_POSVAR("VSE_DESCCP","aHeaderVSE")] := "3"+STR0012+":" // Cota
							aVSE[2,nk,FG_POSVAR("VSE_NOMECP","aHeaderVSE")] := "COTCON"
							aVSE[2,nk,FG_POSVAR("VSE_VALDIG","aHeaderVSE")] := aConsorcio[ni,6]
					EndCase
					aVSE[2,nk,FG_POSVAR("VSE_TIPOCP","aHeaderVSE")] := "1"
					aVSE[2,nk,FG_POSVAR("VSE_TAMACP","aHeaderVSE")] := 15
					aVSE[2,nk,FG_POSVAR("VSE_DECICP","aHeaderVSE")] := 0
					aVSE[2,nk,FG_POSVAR("VSE_PICTCP","aHeaderVSE")] := "@!"
					aVSE[2,nk,FG_POSVAR("VSE_SEQUEN","aHeaderVSE")] := strzero(nj,2)
					aVSE[2,nk,len(aVSE[2,nk])] := .f.
				Next
			EndIf
		Next
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_INCALTº Autor ³ Andre Luis Almeida º Data ³  19/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ ( INCLUI / ALTERA / EXCLUI ) -> ListBox                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_INCALT(cTp,nLinha,lTemFinan,lTemFname,aVS9,cTpPagCon)
Local aRet      := {}
Local aParamBox := {}
Local lOk       := .t.
Local ni        := 0
Local nj        := 0
Local aQuiCon   := {("1="+STR0013),("0="+STR0014)} // Sim / Nao
Local cQuiCon   := "1"
Local dDatCon   := ( dDataBase + FM_SQL("SELECT VSA.VSA_DIADEF FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG='"+cTpPagCon+"' AND VSA.D_E_L_E_T_=' '") )
Local nValCon   := 0
Local cAdmCon   := space(2)
Local cGruCon   := space(5)
Local cCotCon   := space(4)
Local lManut    := FM_PILHA("VEIXX019") // Esta na TELA de Manutencao do Atendimento
Private dDatMax := dDataBase
If lManut // Manutencao do Atendimento - nao validar Data maxima possivel
	dDatMax += 9999
Else // Qtde de Dias para validar Data maxima possivel
	dDatMax += FM_SQL("SELECT VSA.VSA_DIAMAX FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG='"+cTpPagCon+"' AND VSA.D_E_L_E_T_=' '")
EndIf
DbselectArea("VSA")
If cTp == "I" .or. cTp == "A" // Incluir / Alterar
	If VV9->VV9_STATUS == "F"
		aQuiCon := {("1="+STR0013)} // Sim
		MsgAlert(STR0016,STR0005) // Somente é possivel utilizar Consorcio ja quitado, pois este Atendimento ja esta Finalizado! / Atencao
	Else
		If cTp == "A" // Alterar
			If aConsorcio[nLinha,7] > 0 // Linha do aVS9
				nj := aConsorcio[nLinha,7]
				If FS_BAIXADO(aVS9[2,nj,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")],aVS9[2,nj,FG_POSVAR("VS9_PARCEL","aHeaderVS9")])
					MsgStop(STR0017,STR0005) // Impossivel ALTERAR Consorcio com Titulo ja baixado! / Atencao
					Return()
				EndIf
			EndIf
        EndIf		
		If lTemFinan
			aQuiCon := {("1="+STR0013)} // Sim
			MsgAlert(STR0018,STR0005) // Somente é possivel utilizar Consorcio ja quitado, pois ja existe Financiamento para este Atendimento! / Atencao
		EndIf
		If lTemFname
			aQuiCon := {("1="+STR0013)} // Sim
			MsgAlert(STR0019,STR0005) // Somente é possivel utilizar Consorcio ja quitado, pois ja existe Finame para este Atendimento! / Atencao
		EndIf
	EndIf
	If cTp == "I" // Incluir
		nLinha := 0
		If Empty(aConsorcio[1,1])
			aConsorcio := {}
		EndIf
	Else // "A" // Alterar
		If Empty(aConsorcio[1,1])
			Return()
		EndIf
		dDatCon := aConsorcio[nLinha,1]
		nValCon := aConsorcio[nLinha,2]
		cQuiCon := aConsorcio[nLinha,3]
		cAdmCon := left(aConsorcio[nLinha,4],2)
		cGruCon := left(aConsorcio[nLinha,5],5)
		cCotCon := left(aConsorcio[nLinha,6],4)
	EndIf
	aAdd(aParamBox,{2,STR0009,cQuiCon,aQuiCon,30,"",.t.}) // Quitado
	aAdd(aParamBox,{1,STR0007,dDatCon,"@D","MV_PAR02>=dDataBase .and. MV_PAR02<=dDatMax","","",45,.t.}) // Data
	aAdd(aParamBox,{1,STR0008,nValCon,"@E 9,999,999.99","MV_PAR03>=0","","",55,.t.}) // Valor
	aAdd(aParamBox,{1,STR0010,cAdmCon,"@!",'Empty(MV_PAR04) .or. FG_Seek("VV4","MV_PAR04",1,.f.)',"VV4","",30,.t.}) // Administradora
	aAdd(aParamBox,{1,STR0011,cGruCon,"@!","","","",35,.t.}) // Grupo
	aAdd(aParamBox,{1,STR0012,cCotCon,"@!","","","",35,.t.}) // Cota
	While .t.
		If ParamBox(aParamBox,STR0001,@aRet,,,,,,,,.F.) // Consorcio
			lOk := .t.
			If aRet[1] == "0" .and. lTemFinan // Nao deixar digitar Consorcio NAO quitado quando ja existir Financiamento para o Atendimento
				lOk := .f.
				MsgStop(STR0020,STR0005) // Ja existe Financiamento para este Atendimento. Impossivel incluir Consorcio NAO quitado! / Atencao
				For nj := 1 to 6
					aParamBox[nj,3] := aRet[nj]
				Next
            ElseIf aRet[1] == "0" .and. lTemFname // Nao deixar digitar Consorcio NAO quitado quando ja existir Finame para o Atendimento
				lOk := .f.
				MsgStop(STR0021,STR0005) // Ja existe Finame para este Atendimento. Impossivel incluir Consorcio NAO quitado! / Atencao
				For nj := 1 to 6
					aParamBox[nj,3] := aRet[nj]
				Next
			Else
				For ni := 1 to len(aConsorcio)
					If nLinha <> ni
						If ( Alltrim(aRet[4])+aRet[5]+aRet[6] ) == ( Alltrim(aConsorcio[ni,4])+aConsorcio[ni,5]+aConsorcio[ni,6] ) // Nao deixar digitar o mesmo Consorcio (Adm/Grupo/Cota)
							lOk := .f.
							MsgStop(STR0022,STR0005) // Administradora, Grupo e Cota ja digitados! / Atencao
							For nj := 1 to 6
								aParamBox[nj,3] := aRet[nj]
							Next
							Exit
						EndIf
						If ( aRet[1] == "0" .and. aConsorcio[ni,3] == "0" ) .and. ( Alltrim(aRet[4]) <> Alltrim(aConsorcio[ni,4]) ) // Nao deixar digitar Consorcio NAO quitado quando ja possuir outro NAO quitado de outra Administradora
							lOk := .f.
							MsgStop(STR0023,STR0005) // Ja existe Consorcio NAO quitado para outra Administradora! / Atencao
							For nj := 1 to 6
								aParamBox[nj,3] := aRet[nj]
							Next
							Exit
						EndIf
					EndIf
				Next
			EndIf
			If lOk
				If cTp == "I" // Incluir
					aAdd(aConsorcio,{aRet[2],aRet[3],aRet[1],aRet[4],aRet[5],aRet[6],0})
				Else // "A" // Alterar
					aConsorcio[nLinha,1] := aRet[2] // Data
					aConsorcio[nLinha,2] := aRet[3] // Valor
					aConsorcio[nLinha,3] := aRet[1] // Quitado (1=Sim/0=Nao)
					aConsorcio[nLinha,4] := aRet[4] // Administradora
					aConsorcio[nLinha,5] := aRet[5] // Grupo
					aConsorcio[nLinha,6] := aRet[6] // Cota
	        	EndIf
	        	Exit
        	EndIf
		Else
			Exit
		EndIf
	EndDo
ElseIf cTp == "E" // Excluir
	If !Empty(aConsorcio[1,1])
		lOk := .t.
		If VV9->VV9_STATUS == "F"
			If aConsorcio[nLinha,3] == "0"
				MsgStop(STR0024,STR0005) // Impossivel EXCLUIR Consorcio NAO quitado! / Atencao
				lOk := .f.
			EndIf
		Else
			If aConsorcio[nLinha,7] > 0 // Linha do aVS9
				nj := aConsorcio[nLinha,7]
				If FS_BAIXADO(aVS9[2,nj,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")],aVS9[2,nj,FG_POSVAR("VS9_PARCEL","aHeaderVS9")])
					MsgStop(STR0025,STR0005) // Impossivel EXCLUIR Consorcio com Titulo ja baixado! / Atencao
					lOk := .f.
				EndIf
			EndIf
		EndIf
		If lOk
			If MsgYesNo(STR0026,STR0005) // Deseja EXCLUIR o Consorcio selecionado? / Atencao
				aRet := aClone(aConsorcio)
				aConsorcio := {}
				For ni := 1 to len(aRet)
					If ni <> nLinha
						aAdd(aConsorcio,aRet[ni])
					EndIf
				Next
			EndIf
		EndIf
	EndIf
EndIf
If len(aConsorcio) <= 0
	aConsorcio := {{ctod(""),0,"0","","","",0}}
EndIf
oLboxCon:nAt := 1
oLboxCon:SetArray(aConsorcio)
oLboxCon:bLine := { || { Transform(aConsorcio[oLboxCon:nAt,1],"@D"),;
						FG_AlinVlrs(Transform(aConsorcio[oLboxCon:nAt,02],"@E 9,999,999.99")),;
						IIf(aConsorcio[oLboxCon:nAt,03]=="1",STR0013,STR0014),; // Sim / Nao
						IIf(!Empty(aConsorcio[oLboxCon:nAt,04]),Alltrim(aConsorcio[oLboxCon:nAt,04])+" - "+POSICIONE("VV4",1,xFilial("VV4")+aConsorcio[oLboxCon:nAt,04],"VV4_DESCRI"),""),;
						aConsorcio[oLboxCon:nAt,05],;
						aConsorcio[oLboxCon:nAt,06]}}
oLboxCon:Refresh()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_BAIXADOº Autor ³ Andre Luis Almeida º Data ³  19/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ VERIFICA SE O TITULO ESTA BAIXADO                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_BAIXADO(cTipTit,cParcel)
Local lRet      := .f.
Local cPrefOri  := GetNewPar("MV_PREFVEI","VEI")
Local cNumTit   := "V"+Right(VV9->VV9_NUMATE,TamSx3("E1_NUM")[1]-1)
Local cNumNFI   := VV0->VV0_NUMNFI
Local cQuery    := ""
Local cPreTit   := &(GetNewPar("MV_PTITVEI","''")) // Prefixo dos Titulos de Veiculos
If left(GetNewPar("MV_TITATEN","0"),1) == "0" // Geracao dos Titulos no momento da geracao da NF
	If !Empty(cNumNFI) // Titulos gerados com o Nro da Nota Fiscal
		SF2->(DbSetOrder(1)) // F2_FILIAL + F2_DOC + F2_SERIE
		If SF2->(DbSeek(xFilial("SF2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI))
			cPreTit := SF2->F2_PREFIXO
		EndIf
	EndIf
EndIf
cQuery := "SELECT SE1.R_E_C_N_O_ AS RECSE1 FROM "+RetSQLName("SE1")+" SE1 WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND "
cQuery += "SE1.E1_PREFIXO='"+cPreTit+"' AND "
cQuery += "( SE1.E1_NUM='"+cNumTit+"' "
If !Empty(cNumNFI) // Titulos gerados com o Nro da Nota Fiscal
	cQuery += "OR SE1.E1_NUM='"+cNumNFI+"'"
EndIf
cQuery += " ) AND SE1.E1_TIPO='"+cTipTit+"' AND SE1.E1_PREFORI='"+cPrefOri+"' AND "
If cParcel <> NIL
	cQuery += "SE1.E1_PARCELA='"+cParcel+"' AND "
Else
	cQuery += "SE1.E1_PARCELA=' ' AND "
EndIf
cQuery += "( SE1.E1_BAIXA <> ' ' OR SE1.E1_SALDO <> SE1.E1_VALOR )"
cQuery += " AND SE1.E1_FILORIG='"+xFilial("VV9")+"' AND SE1.D_E_L_E_T_=' '"
If FM_SQL(cQuery) > 0
	lRet := .t.
EndIf
Return(lRet)