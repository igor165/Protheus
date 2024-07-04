#INCLUDE "TMKA380D.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTMKA380D  บAutor  ณMicrosiga 			 บ Data ณ  01/12/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAgenda do operador. Marketing Ativo.                        บฑฑ
ฑฑบ          ณFuncoes sem tela utilizadas pela agenda do operador.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Call Center                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK380Leg  บAutor  ณMicrosiga           บ Data ณ  12/09/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para retorno da Legenda das atividades               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1: Status para retorno do bmp                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk380Leg(cStatus)
Local oNova        	:= LoadBitmap( GetResources(), "br_vermelho" )
Local oTrabalhada  	:= LoadBitmap( GetResources(), "br_azul" )
Local oLegenda		:= LoadBitmap( GetResources(), "br_verde" )

If cStatus == "1"
	oLegenda := oNova
ElseIf cStatus =="3"
	oLegenda := oTrabalhada          
Else
	oLegenda := LoadBitmap( GetResources(), "br_verde" )	
EndIf

Return(oLegenda)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออออหออออัอออออออออออปฑฑ
ฑฑบPrograma  ณTk380PDetalhes บAutor  ณMicrosiga			 บDataณ12/17/03   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออออสออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza painel de detalhes da agenda do operador.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpA1: Array com as informacoes do painel 1 de detalhes.    บฑฑ
ฑฑบ          ณExpA2: Vetor com a atividade selecionada na agenda.         บฑฑ 
ฑฑบ          ณExpO1: Objeto do painel de pendecia.                        บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk380PDetalhes(aDet_Panel,	aItemSel,	oPDetalhes)
Local x := 0 // Contador para FOR
Local aTipo    := Tk380Box("U4_TIPO")    	//Retorna array do combo box
Local aTele    := Tk380Box("U4_TELE")    	//Retorna array do combo box
Local aForma   := Tk380Box("U4_FORMA")   	//Retorna array do combo box
Local aTipoTel := Tk380Box("U4_TIPOTEL") 	//Retorna array do combo box
Local aTipoEnd := Tk380Box("U4_TIPOEND") 	//Retorna array do combo box
Local nTipo	   := 0						 	//Valor informado na lista de contatos.
Local nTele    := 0						 	//Valor informado na lista de contatos.
Local nForma   := 0						 	//Valor informado na lista de contatos.
Local nTipoTel := 0						 	//Valor informado na lista de contatos.
Local nTipoEnd := 0						 	//Valor informado na lista de contatos.


DbSelectArea("SU4")
DbSetOrder(1)

If DbSeek(xFilial("SU4")+aItemSel[1])// Codigo da lista.

	nTipo   := Iif(val(SU4->U4_TIPO)=0    ,Len(aTipo)    ,val(SU4->U4_TIPO)     )
	nTele   := Iif(val(SU4->U4_TELE)=0    ,Len(aTele)    ,val(SU4->U4_TELE)     )
	nForma  := Iif(val(SU4->U4_FORMA)=0   ,Len(aForma)   ,val(SU4->U4_FORMA)    )
	nTipoTel:= Iif(val(SU4->U4_TIPOTEL)=0 ,Len(aTipoTel) ,val(SU4->U4_TIPOTEL)  )
	nTipoEnd:= Iif(val(SU4->U4_TIPOEND)=0 ,Len(aTipoEnd) ,val(SU4->U4_TIPOEND)  )

	aDet_Panel[01,1]:=STR0001 + AllTrim(Upper(aTipo[nTipo])) //"Lista de "
	aDet_Panel[02,1]:=STR0002 +AllTrim(Posicione("SX2",1,Posicione("SU6",1,xFilial("SU6")+SU4->U4_LISTA,"U6_ENTIDA") ,"X2NOME()")) //"Entidade: "
	aDet_Panel[03,1]:=STR0003 + AllTrim(Upper(aTele[nTele])) //"Rotina: "
	aDet_Panel[04,1]:=STR0004 + AllTrim(Upper(Posicione("SUO",1,xFilial("SUO")+SU4->U4_CODCAMP,"UO_DESC"))) //"Campanha: "
	aDet_Panel[05,1]:=STR0005 + AllTrim(Upper(Posicione("SUZ",1,xFilial("SUZ")+SU4->U4_SCRIPT,"UZ_DESC"))) //"Script: "
	aDet_Panel[06,1]:=STR0006 + AllTrim(Upper(Posicione("ACD",1,xFilial("ACD")+SU4->U4_EVENTO,"ACD_DESC"))) //"Evento: "
	aDet_Panel[07,1]:=STR0007 + AllTrim(Upper(aForma[nForma])) //"Meio de Intera็ใo: "
	aDet_Panel[08,1]:=STR0008 + AllTrim(Upper(aTipotel[nTipoTel])) //"Tipo de Telefone: "
	aDet_Panel[09,1]:=STR0009 + AllTrim(Upper(aTipoEnd[nTipoEnd])) //"Tipo de Endere็o: "
	aDet_Panel[10,1]:=STR0010 + Alltrim(Upper(SU4->U4_ASSUNTO)) //"Assunto do E-mail: "

Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicializa informacoes do painel de detalhes.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aDet_Panel[01,1]:=STR0001 //"Lista de "
	aDet_Panel[02,1]:=STR0002 //"Entidade: "
	aDet_Panel[03,1]:=STR0003 //"Rotina: "
	aDet_Panel[04,1]:=STR0004 //"Campanha: "
	aDet_Panel[05,1]:=STR0005 //"Script: "
	aDet_Panel[06,1]:=STR0006 //"Evento: "
	aDet_Panel[07,1]:=STR0007 //"Meio de Intera็ใo: "
	aDet_Panel[08,1]:=STR0008 //"Tipo de Telefone: "
	aDet_Panel[09,1]:=STR0009 //"Tipo de Endere็o: "
	aDet_Panel[10,1]:=STR0010 //"Assunto do E-mail: "
	
EndIf	
	
For x := 1 To Len(aDet_Panel)
	If aDet_Panel[x][2] <> Nil
		aDet_Panel[x][2]:Refresh()  
	EndIf
Next x

If oPDetalhes <> Nil
	oPDetalhes:Refresh() 
EndIf 


Return Nil 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออออหออออัอออออออออออปฑฑ
ฑฑบPrograma  ณTk380PPendenciaบAutor  ณMicrosiga			 บDataณ12/17/03   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออออสออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza painel de pendencias da agenda do operador.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpA1: Array com as informacoes do painel 1 de pendencias.  บฑฑ
ฑฑบ          ณExpA2: Vetor com a atividade selecionada na agenda.         บฑฑ 
ฑฑบ          ณExpO1: Objeto do painel de pendecia.                        บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk380PPendencia(aPend_Panel,	aItemSel,	oPPendencia)
Local x 		:= 0 // Contador para FOR
Local cCompany	:= ""

If VAL(aItemSel[9]) == PENDENCIA // validacao de pendencia
	
	
	DbSelectArea("SU6")
	DbSetOrder(1)
	
	If DbSeek(xFilial("SU6")+aItemSel[1])// Codigo da lista.
	
		DbSelectArea("SU5")
		DbSetOrder(1)
		If DbSeek(xFilial("SU5")+SU6->U6_CONTATO)	
			aPend_Panel[1,1]	:= STR0011 + FATPDObfuscate(SU5->U5_CONTAT,"U5_CONTAT") //"Contato: "
			aPend_Panel[2,1]	:= STR0012 + FATPDObfuscate(SU5->U5_MUN,"U5_MUN")  //"Cidade: "
			aPend_Panel[3,1]	:= 	STR0013 + FATPDObfuscate(SU5->U5_EST,"U5_EST") //"Estado: "
		EndIf
	
		If !Empty(aItemSel[7])
			Do Case
				Case aItemSel[7] == "1"	// Telemarketing
						DbSelectArea("SUC")
						DbSetOrder(1)
							
						If DbSeek(xFilial("SUC") + aItemSel[8])
							
							cCompany := Trim(TkEntidade(SUC->UC_ENTIDAD,Trim(SUC->UC_CHAVE),1))

							If SUC->UC_ENTIDAD == "SA1"
								cCompany := FATPDObfuscate(cCompany,"A1_NOME")
							ElseIf SUC->UC_ENTIDAD == "SUS"
								cCompany := FATPDObfuscate(cCompany,"US_NOME")
							ElseIf SUC->UC_ENTIDAD == "ACH"
								cCompany := FATPDObfuscate(cCompany,"ACH_RAZAO ")
							EndIf

							aPend_Panel[4,1] := If(AllTrim(SUC->UC_HRPEND)<>":",STR0014,"") + Trim(SUC->UC_HRPEND)	  //"Retorno: "
							aPend_Panel[5,1] := STR0015 + cCompany	 //"Empresa: "
	
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณData da execussao da agenda.ณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							aPend_Panel[6,1] :=  STR0016 + DTOC(aItemSel[3]) //"Data da Pend๊ncia: "
	
						EndIf
		
				Case aItemSel[7] == "2"	// Televendas
						DbSelectArea("SUA")
						DbSetOrder(1)
						If DbSeek(xFilial("SUA") + aItemSel[8])
							aPend_Panel[4,1] := If(AllTrim(SUA->UA_HRPEND)<>":",STR0014,"") + Trim(SUA->UA_HRPEND)	  //"Retorno: "
							If SUA->UA_Prospec
								cCompany := Trim(Posicione("SUS",1,xFilial("SUS")+SUA->UA_CLIENTE+SUA->UA_LOJA,"SUS->US_NOME")) 
								aPend_Panel[5,1] :=  STR0015 + FATPDObfuscate(cCompany,"US_NOME") //"Empresa: "
							Else
								cCompany := Trim(Posicione("SA1",1,xFilial("SA1")+SUA->UA_CLIENTE+SUA->UA_LOJA,"SA1->A1_NOME"))
								aPend_Panel[5,1] := STR0015 + FATPDObfuscate(cCompany,"A1_NOME")  //"Empresa: "
							EndIf
						
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณData da execussao da agenda.ณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							aPend_Panel[6,1] :=  STR0016 + DTOC(aItemSel[3]) //"Data da Pend๊ncia: "
						
						EndIf
		
		
				Case aItemSel[7] == "3"	// Telecobranca
						DbSelectArea("ACF")
						DbSetOrder(1)
						If DbSeek(xFilial("ACF") + aItemSel[8])
							aPend_Panel[4,1] := If(AllTrim(ACF->ACF_HRPEND)<>":",STR0014,"") + Trim(ACF->ACF_HRPEND)	  //"Retorno: "
							cCompany := Trim(Posicione("SA1",1,xFilial("SA1")+ACF->ACF_CLIENT+ACF->ACF_LOJA,"SA1->A1_NOME"))
							aPend_Panel[5,1] := STR0015 + FATPDObfuscate(cCompany,"A1_NOME")	  //"Empresa: "
	
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณData da execussao da agenda.ณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							aPend_Panel[6,1] :=  STR0016 + DTOC(aItemSel[3]) //"Data da Pend๊ncia: "
						EndIf
				EndCase		
		
			
		EndIf	
		
	Else
		aPend_Panel[1,1]:=STR0011 //"Contato: "
		aPend_Panel[2,1]:=STR0012 //"Cidade: "
		aPend_Panel[3,1]:=STR0013 //"Estado: "
		aPend_Panel[4,1]:=STR0014 //"Retorno: "
		aPend_Panel[5,1]:=STR0015 //"Empresa: "
		aPend_Panel[6,1]:=STR0016 //"Data da Pend๊ncia: "
	EndIf
Else
	aPend_Panel[1,1]:=STR0011 //"Contato: "
	aPend_Panel[2,1]:=STR0012 //"Cidade: "
	aPend_Panel[3,1]:=STR0013 //"Estado: "
	aPend_Panel[4,1]:=STR0014 //"Retorno: "
	aPend_Panel[5,1]:=STR0015 //"Empresa: "
	aPend_Panel[6,1]:=STR0016 //"Data da Pend๊ncia: "
EndIf

	
For x := 1 To Len(aPend_Panel)
	If aPend_Panel[x][2] <> Nil
		aPend_Panel[x][2]:Refresh() 
	EndIf
Next x

If oPPendencia <> Nil
	FATPDLogUser('TK380PPEND')	// Log de Acesso LGPD
	oPPendencia:Refresh()
EndIf

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหออออออัอออออออออออออออออออหออออัอออออออออออปฑฑ
ฑฑบPrograma  ณTk380AtuSaudacaoบAutor ณMicrosiga			 บDataณ12/17/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสออออออฯอออออออออออออออออออสออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza dados do cabecalho da agenda do operador.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1: Objeto do status do SU6                              บฑฑ
ฑฑบ          ณExpO2: Objeto com a meta da campanha.                       บฑฑ 
ฑฑบ          ณExpA1: Vetor com o item selecionado da agenda.              บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk380AtuSaudacao(oU6Status,	oUOMeta,	aItemSel)
Local nExecutado := 0 			// Variavel para armazenar o valor dos itens executados na lista.
Local nPendente  := 0 			// Variavel para armazenar o valor dos itens pendentes na lista.
Local nTotal     := 0  			// Variavel para armazenar o valor Total dos itens da lista.


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEfetua calculo de percentual executado da lista.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SU6")
DbSetOrder(1)
If DbSeek(xFilial("SU6")+aItemSel[1])
//(executado*100) / total = Percentual executado
	While !Eof() .AND. (xFilial("SU6") == SU6->U6_FILIAL) .AND. (aItemSel[1] == SU6->U6_LISTA)
		If SU6->U6_STATUS == '3'
			nExecutado++
		Else
			nPendente++
		EndIf
	
		DbSkip()
	End
                      
	nTotal:= nExecutado+nPendente
	
	oU6Status:cCaption := Transform(((nExecutado*100) / nTotal),"999")+"%" // Percentual executado da lista.
	oU6Status:Refresh()
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBusca informacoes da campanhaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SU4")
DbSetOrder(1)
If DbSeek(xFilial("SU4")+aItemSel[1])
	DbSelectArea("SUO")
	DbSetOrder(1)
	If DbSeek(xFilial("SUO")+SU4->U4_CODCAMP)
	  oUOMeta:cCaption := Transform(SUO->UO_META,PesqPict("SUO","UO_META"))
	  oUOMeta:Refresh()
	EndIf
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบFuncao    ณTk380RetRotบAutor  ณMicrosiga           บ Data ณ  23/12/03  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a rotina correspondente a lista. Tratamento para   บฑฑ
ฑฑบ          ณ conte๚do vazio.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณ Valor do campo U4_TELE                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk380RetRot(cPar) 
Local aRotina		:= {} 				    	// Array do combobox.
Local cDado			:= ""						// Retorno da funcao.

If !Empty(cPar)
	aRotina := Tk380Box("U4_TELE")
    cDado := Alltrim(aRotina[Val(cPar)])  // aRotina[Val(aAtividades[oLbx:nAt,7])]}},;
EndIf

Return cDado

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk380BaixaบAutor  ณMicrosiga           บ Data ณ  10/07/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se os titulos da lista de cobranca foram baixadas eบฑฑ
ฑฑบ          ณatualiza o status do atendimento como pago e retira da agen-บฑฑ
ฑฑบ          ณda caso nao tudo tenha sido pago.                           บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ Tk380Baixa(ExpC1)                                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Codigo da Lista a ser verificada                   ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                   	  บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAndrea F. ณ24/04/04ณ811   ณBOPS 97565 - Passagem de parametro na funcaoบฑฑ
ฑฑบ          ณ        ณ      ณpara evitar desposicionamento. Usar o mesmo บฑฑ
ฑฑบ          ณ        ณ      ณmetodo que verifica  se o titulo esta pago  บฑฑ
ฑฑบ          ณ        ณ      ณexistente nos fontes da telecobranca.       บฑฑ
ฑฑบAndrea F. ณ25/04/06ณ811   ณBOPS 97587 - Gravar a funcao que encerrou a บฑฑ
ฑฑบ          ณ        ณ      ณpendencia de telecobranca.                  บฑฑ
ฑฑบMarcelo K.ณ06/06/02ณ710   ณBops 101493 - Correcao da sintaxe do alias  บฑฑ
ฑฑบ          ณ        ณ      ณda tabela SU4                               บฑฑ
ฑฑบMichel M. ณ03/01/07ณ811   ณBops 116545 - Otimizando verificacao de tit.บฑฑ
ฑฑบ          ณ        ณ      ณbaixados do Telecobranca quando utilizado   บฑฑ
ฑฑบ          ณ        ณ      ณTopConnect.                                 บฑฑ
ฑฑบMichel M. ณ09/01/07ณ811   ณBops 117077 - Corrigida nao-conformidade    บฑฑ
ฑฑบ          ณ        ณ      ณao Abrir mais de 512 consultas.             บฑฑ
ฑฑบ          ณ        ณ      ณ                                            บฑฑ
ฑฑบ          ณ        ณ      ณ                                            บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk380Baixa(cLista)

Local aArea		:= GetArea()
Local lRet		:= .F.
Local nContACG	:= 0
Local nAltACG	:= 0
Local nContSU6	:= 0
Local nAltSU6	:= 0
Local cTMPU4	:= "SU4" 
Local cFilOrig	:= ""
Local nSE1  	:= 0           	// Contador dos titulos baixados do SE1
Local nSK1		:= 0			// Contador dos titulos baixados do SK1 
Local cAliasSK1 := "SK1"		//Armazena a query para consulta via TOP ou Codebase 
Local cAliasSE1 := "SE1"		//Armazena a query para consulta via TOP ou Codebase   
Local cAliasSU6 := "SU6"		//Armazena a query para consulta via TOP ou Codebase
#IFDEF TOP
	Local cAliasAux := ""			//Armazena temporariamente o alias de um consulta TOP
#ENDIF

DEFAULT cLista	:= (cTMPU4)->U4_LISTA

#IFDEF TOP
	cTMPU4 := "TMPU4"
#ENDIF


#IFDEF TOP 
	cAliasSU6 := GetNextAlias()
	BeginSQL alias cAliasSU6
		SELECT	U6_FILIAL,	U6_LISTA,	U6_CODLIG,	U6_CODENT,
				U6_STATUS,	U6_CODIGO
		FROM 	%table:SU6% SU6
		WHERE 	SU6.U6_FILIAL = %xFilial:SU6% AND 				
				SU6.%notDel% AND
				SU6.U6_LISTA = %exp:cLista% AND
				SU6.U6_STATUS < '3'
		ORDER BY %Order:SU6,1%	
	EndSQL 	
	
#ELSE
	DbSelectArea("SU6")	
	DbSetOrder(1)                 
	DbSeek(xFilial("SU6") + cLista)
#ENDIF    

If !Eof()
	While	!Eof()								.AND.;
			(cAliasSU6)->U6_FILIAL == xFilial("SU6")	.AND.;
			(cAliasSU6)->U6_LISTA == cLista	
		
		nContSU6++
		If !Empty((cAliasSU6)->U6_CODLIG)	// Se a lista possuir um atendimento
			DbSelectArea("ACG")
			DbSetOrder(1)
			If DbSeek(xFilial("ACG") + (cAliasSU6)->U6_CODLIG)
				While	!Eof()								.AND.;
						ACG->ACG_FILIAL == xFilial("ACG")	.AND.;
						ACG->ACG_CODIGO == (cAliasSU6)->U6_CODLIG
					
					nContACG++

					cFilOrig:= ACG->ACG_FILORI
		
					DbSelectArea("SE1")
					DbSetOrder(2)//Filial + Cliente + Loja + Prefixo + Titulo + Parcela + Tipo
					If DbSeek(cFilOrig + AllTrim((cAliasSU6)->U6_CODENT) + ACG->ACG_PREFIX + ACG->ACG_TITULO + ACG->ACG_PARCEL + ACG->ACG_TIPO)
					
						If SE1->E1_SALDO <= 0
							nAltACG++
							DbSelectarea("ACG")
							RecLock("ACG", .F.)
							ACG->ACG_STATUS := "1"
							MsUnLock()
						Endif
					Endif
						
					DbSelectArea("ACG")
					DbSkip()
				End
			End	

			If (nContACG > 0) .AND. (nContACG == nAltACG)
				nAltSU6++  
				#IFDEF TOP
					DbSelectArea("SU6")
					DbSetOrder(1)						
					DbSeek(	(cAliasSU6)->U6_FILIAL + (cAliasSU6)->U6_LISTA + (cAliasSU6)->U6_CODIGO)
					cAliasAux := cAliasSU6 
					cAliasSU6 := "SU6"						
				#ELSE
					DbSelectarea(cAliasSU6)
				#ENDIF					
				RecLock("SU6", .F.)
				(cAliasSU6)->U6_STATUS := "3"
				(cAliasSU6)->U6_ROTINA := "TK380BAIXA"

				MsUnLock() 
				#IFDEF TOP 
					cAliasSU6 := cAliasAux				
				#ENDIF				
			Endif
			nContACG	:= 0
			nAltACG		:= 0
		
		Else 
			cAliasSK1 := "SK1"
			cAliasSE1 := "SE1"
			#IFDEF TOP  
				cAliasSK1		:= GetNextAlias()						// Pega o proximo Alias Disponivel
				cAliasSE1		:= cAliasSK1			
				BeginSQL alias cAliasSK1 
					SELECT 	K1_FILIAL,	K1_CLIENTE,	K1_LOJA,	E1_SALDO,
							K1_FILORIG,	K1_PREFIXO,	K1_NUM,		K1_PARCELA, 
							K1_TIPO,	K1_FILORIG								
					FROM %table:SK1% SK1, %table:SE1% SE1
					WHERE 	SK1.K1_FILIAL = %xFilial:SK1% AND 							
							SK1.%notDel% AND
							SE1.%notDel% AND							
							SK1.K1_CLIENTE = %exp:Substr(AllTrim((cAliasSU6)->U6_CODENT),1,TamSX3("K1_CLIENTE")[1])% AND 
							SK1.K1_LOJA  = %exp:Substr(AllTrim((cAliasSU6)->U6_CODENT),TamSX3("K1_CLIENTE")[1]+1,TamSX3("K1_LOJA")[1])% AND 							
							SE1.E1_FILIAL = SK1.K1_FILORIG AND 
							SE1.E1_CLIENTE = SK1.K1_CLIENTE AND
							SE1.E1_LOJA = SK1.K1_LOJA AND
							SE1.E1_PREFIXO = SK1.K1_PREFIXO AND
							SE1.E1_NUM = SK1.K1_NUM AND
							SE1.E1_PARCELA = SK1.K1_PARCELA AND
							SE1.E1_TIPO = SK1.K1_TIPO
					ORDER BY %Order:SK1,4%			
				EndSql
				cAliasSE1 := cAliasSK1			
			#ELSE  
				DbSelectArea("SK1")
				DbSetOrder(4)	// K1_FILIAL+K1_CLIENTE+K1_LOJA+DTOS(K1_VENCREA)
				DbSeek(xFilial("SK1") + AllTrim((cAliasSU6)->U6_CODENT) )						
			#ENDIF						

			While !Eof()  .AND. (cAliasSK1)->K1_FILIAL == xFilial("SK1") .AND. ;
					   (AllTrim((cAliasSK1)->K1_CLIENTE + (cAliasSK1)->K1_LOJA)) == (AllTrim((cAliasSU6)->U6_CODENT) )
				
				nSK1++
				
				cFilOrig	:= (cAliasSK1)->K1_FILORIG
	            
				#IFNDEF TOP
					DbSelectarea("SE1")
					DbSetOrder(2)//Filial + Cliente + Loja + Prefixo + Titulo + Parcela + Tipo
					DbSeek(cFilOrig + AllTrim((cAliasSU6)->U6_CODENT)+ SK1->K1_PREFIXO + SK1->K1_NUM + SK1->K1_PARCELA + SK1->K1_TIPO)
				#ENDIF
				
				If (cAliasSE1)->E1_SALDO <= 0
					nSE1++     
					#IFDEF TOP
						DbSelectArea("SK1")
						DbSetOrder(1)						
						DbSeek(	(cAliasSK1)->K1_FILIAL  + (cAliasSK1)->K1_PREFIXO + (cAliasSK1)->K1_NUM +;
								(cAliasSK1)->K1_PARCELA + (cAliasSK1)->K1_TIPO + (cAliasSK1)->K1_FILORIG)
						cAliasAux := cAliasSK1 
						cAliasSK1 := "SK1"						
					#ELSE
						DbSelectArea(cAliasSK1)						
					#ENDIF										
					RecLock("SK1", .F., .T.)
					DbDelete()
					MsUnLock()
					#IFDEF TOP                  
						cAliasSK1 := cAliasAux			
					#ENDIF
				Endif         
	           
				Dbselectarea(cAliasSK1)
				Dbskip()	
			End
			
			#IFDEF TOP                
				Dbselectarea(cAliasSK1)
				DbCloseArea()
			#ENDIF			
			
			If nSK1 == nSE1      
				#IFDEF TOP
					DbSelectArea("SU6")
					DbSetOrder(1)						
					DbSeek(	(cAliasSU6)->U6_FILIAL + (cAliasSU6)->U6_LISTA + (cAliasSU6)->U6_CODIGO)
					cAliasAux := cAliasSU6 
					cAliasSU6 := "SU6"						
				#ELSE
					DbSelectarea(cAliasSU6)
				#ENDIF					
				RecLock("SU6", .F., .T.)
				(cAliasSU6)->U6_STATUS := "3"
				(cAliasSU6)->U6_ROTINA := "TK380BAIXA"
	
				MsUnLock()
				nAltSU6++
				#IFDEF TOP 
					cAliasSU6 := cAliasAux				
				#ENDIF
			Endif	
			
			nSK1 := 0
			nSE1 := 0
		Endif
		
		DbSelectArea((cAliasSU6))
		DbSkip()
	End
Endif

#IFDEF TOP  
	DbSelectArea((cAliasSU6))
	DbCloseArea()
#ENDIF
	
If (nContSU6 > 0) .AND. (nContSU6 == nAltSU6)
	DbSelectarea("SU4")
	DbSetOrder(1)
	DbSeek(xFilial("SU4") + (cTMPU4)->U4_LISTA)
	RecLock("SU4", .F.)
	SU4->U4_STATUS := "2"
	SU4->U4_ROTINA := "TK380BAIXA"
	
	MsUnLock()
	lRet := .T.
Endif

RestArea(aArea)

Return(lRet)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} Tk380AtuPercent

Verifica a execu็ใo da lista de contatos

@sample	Tk380AtuPercent(cLista)

@param		ExpC1 - Codigo da lista a ser verificado

@return	ExpN - Porcentagem de execu็ใo da lista

@author	Servi็os
@since		07/04/2016
@version	11
/*/
//------------------------------------------------------------------------------
Function Tk380AtuPercent(cLista)

Local nExecutado 	:= 0 			// Variavel para armazenar o valor dos itens executados na lista.
Local nPendente  	:= 0 			// Variavel para armazenar o valor dos itens pendentes na lista.
Local nTotal     	:= 0  			// Variavel para armazenar o valor Total dos itens da lista.
Local aAreaSU6		:= SU6->(GetArea())

//Efetua calculo de percentual executado da lista.
DbSelectArea("SU6")
DbSetOrder(1)
If DbSeek(xFilial("SU6")+cLista)
//(executado*100) / total = Percentual executado
	While !Eof() .AND. (xFilial("SU6") == SU6->U6_FILIAL) .AND. (cLista == SU6->U6_LISTA)
		If SU6->U6_STATUS == '3'
			nExecutado++
		Else
			nPendente++
		EndIf
	
		DbSkip()
	End
                      
	nTotal:= nExecutado+nPendente
	nTotal := ((nExecutado*100) / nTotal)
EndIf

RestArea(aAreaSU6)

Return nTotal
 
//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   



//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informa็๕es enviadas, 
    quando a regra de auditoria de rotinas com campos sensํveis ou pessoais estiver habilitada
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que serแ utilizada no log das tabelas
    @param nOpc, Numerico, Op็ใo atribuํda a fun็ใo em execu็ใo - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria nใo esteja aplicada, tamb้m retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun็ใo que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
