#include "protheus.ch"
Static oTmpTbDIP
Static oTmpTbDIC
/*                                                                  	
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบPrograma  ณDICP_MEX  บAutor  ณMarcello            บFecha ณ 24/10/2008   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบDesc.     ณCria um arquivo temporario com as informacoes necessarias    บฑฑ
ฑฑบ          ณpara a geracao do arquivo txt para a DICP - Mexico           บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑบParametrosณnFilIni    - Filial inicial a ser considerado para a operacaoบฑฑ
ฑฑบ          ณnFilFin    - Filial final a ser considerada para a operacao  บฑฑ
ฑฑบ          ณcAnexo     - Tipo de informacao                              บฑฑ
ฑฑบ          ณ             0 clientes, 1 fornecedores, 2 ambos             บฑฑ
ฑฑบ          ณnVlrMinimo - Valor minimo a ser considerado para a operacao  บฑฑ
ฑฑบ          ณdDtInicial - Data inicial a ser considerada para a operacao  บฑฑ
ฑฑบ          ณdDtFinal   - Data inicial a ser considerada para a operacao  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณDICP - MATA950 - Mexico                                      บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.              บฑฑ
ฑฑฬฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤนฑฑ
ฑฑบProgramador ณData    ณ BOPS     ณ Motivo da Alteracao                   บฑฑ
ฑฑฬฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤนฑฑ
ฑฑบAlf. Medranoณ04/01/17ณSERINN001-896ณcreaci๓n de tablas temporales con   บฑฑ
ฑฑบ            ณ        ณ          ณFWTemporaryTable en funcion DICPMEX()  บฑฑ
ฑฑบ            ณ        ณ          ณse inicializa varibles estaticas       บฑฑ
ฑฑบ            ณ        ณ          ณoTempTableDIP y oTempTableDIC encabeza บฑฑ
ฑฑบ            ณ        ณ          ณdo del fuente. Se agrega Fuc DICPDel   บฑฑ
ฑฑบ            ณ        ณ          ณpara limpiar obj de tablas temporales. บฑฑ
ฑฑบAlf. Medranoณ09/01/17ณ          ณse recorta el nombre de variables Statcบฑฑ
ฑฑบ            ณ        ณ          ณa 9 caracteres. oTmpTbDIP y oTmpTbDIC  บฑฑ
ฑฑบAlf. Medranoณ16/01/17ณ          ณMerge Main Vs 12.1.15                  บฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function DICPMEX(cFilIni,cFilFin,cAnexo,nVlrMinimo,dDtInicial,dDtFinal)
Local cAliasFor	:= "DIP"
Local cAliasCli	:= "DIC"
Local cAliasSF3	:= ""
Local cArqForn	:= ""
Local cArqClie	:= ""
Local cIndSF3	:= ""
Local cChave	:= ""
Local cQuery	:= ""
Local cCliFor	:= ""
Local cLoja		:= ""
Local cFilProc	:= ""
Local cCpoIVC	:= ""
Local cCpoIEP	:= ""
Local cCpoImp	:= ""
Local cIEPS		:= SubStr(GetNewPar("MV_IEPS ",""),1,3)
Local nValor	:= 0
Local nRelac	:= 0
Local nExter	:= 0
Local nTtlExerc	:= 0	//total de operaciones con todos los clientes/proveedores
Local nTtlRelac	:= 0	//total de operaciones con clientes/proveedores 
Local nTtlExter	:= 0	//total de operaciones con clientes/proveedores extranjeros
Local nTotal	:= 0
Local nIndex	:= 0
Local nNrConsec	:= 0
Local aArea		:= {}
Local aEstru	:= {}

Default nVlrMinimo	:= 50000
Default cAnexo		:= "0"
Default cFilIni		:= "01"
Default cFilFin		:= "01"
Default dDtInicial	:= Ctod("01/01" + Strzero(Year(dDatabase),4))
Default dDtFinal	:= Ctod("31/12" + Strzero(Year(dDatabase),4))
//
DbSelectArea("SFB")
DbSetOrder(1)
If SFB->(DbSeek(xFilial("SFB")+"IVC"))
	cCpoIVC := "F3_VALIMP" + AllTrim(SFB->FB_CPOLVRO)
Else
	cCpoIVC := ""
Endif
If SFB->(DbSeek(xFilial("SFB")+cIEPS))
	cCpoIEP := "F3_VALIMP" + AllTrim(SFB->FB_CPOLVRO)
Else
	cCpoIEP := ""
Endif
//
nVlrMinimo := Int(nVlrMinimo)		//no se debe considerar las decimales
aArea := GetArea()
#IFDEF TOP
	cAliasSF3 := GetNextAlias()
	cQuery := "select F3_CLIEFOR,F3_LOJA,F3_TIPOMOV,F3_VALMERC,F3_ESPECIE" 
	If !Empty(cCpoIVC)
		cQuery += "," + cCpoIVC
	Endif
	If !Empty(cCpoIEP)
		cQuery += "," + cCpoIEP
	Endif
	cQuery += " from " + RetSqlName("SF3")
	cQuery += " where F3_ENTRADA >= '" + Dtos(dDtInicial) + "'"
	cQuery += " and F3_ENTRADA <= '" + Dtos(dDtFinal) + "'"
	If FWModeAccess("SF3",3)=="E"
		cQuery += " and F3_FILIAL >='" + cFilIni + "'"
		cQuery += " and F3_FILIAL <= '" + cFilFin + "'"
	Endif
	If cAnexo $ "0,1"
		If cAnexo == "1"	//proveedores
			cQuery += " and F3_TIPOMOV = 'C'"
		Else
			cQuery += " and F3_TIPOMOV = 'V'"
		Endif
	Endif
	cQuery += " and F3_DTCANC=''"
	cQuery += " and D_E_L_E_T_=''"
	cQuery += " order by F3_TIPOMOV,F3_CLIEFOR,F3_LOJA"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)
#ELSE
	cIndSF3 := CriaTrab(nil,.F.)
	cChave  := "F3_TIPOMOV+F3_CLIEFOR+F3_LOJA"
	cQuery  := "Dtos(F3_ENTRADA) >= '" + Dtos(dDtInicial) + "' .And. Dtos(F3_ENTRADA) <= '" + Dtos(dDtFinal) + "'"
	If FWModeAccess("SF3",3)=="E"
		cQuery  += " .And. F3_FILIAL >= '" + cFilIni + "' .And. F3_FILIAL <= '" + cFilFin + "'"
	Endif
	If cAnexo $ "0,1"
		If cAnexo == "1"	//proveedores
			cQuery += " .And. F3_TIPOMOV == 'C'"
		Else
			cQuery += " .And. F3_TIPOMOV == 'V'"
		Endif
	Endif
	cQuery += " .And. Empty(F3_DTCANC)"
	IndRegua("SF3",cIndSF3 +  OrdBagExt(),cChave,,cQuery,"Selecionando Registros...")
	nIndex := RetIndex("SF3")
 	SF3->(dbSetIndex(cIndSF3 + OrdBagExt()))
	SF3->(dbSetOrder(nIndex+1))
	cAliasSF3 := "SF3"
#ENDIF
(cAliasSF3)->(DbGoTop())
Aadd(aEstru,{"CLAVE","C",18,0})
Aadd(aEstru,{"NRCONSEC","C",13,0})
Aadd(aEstru,{"RFC","C",13,0})
Aadd(aEstru,{"RAZON","C",60,0})
Aadd(aEstru,{"APELLPAT","C",20,0})
Aadd(aEstru,{"APELLMAT","C",20,0})
Aadd(aEstru,{"NOMBRE","C",20,0})
Aadd(aEstru,{"CURP","C",18,0})
Aadd(aEstru,{"MONTONETO","N",13,0})
Aadd(aEstru,{"OPERACION","N",1,0})
Aadd(aEstru,{"CALLE","C",60,0})
Aadd(aEstru,{"NREXT","C",15,0})
Aadd(aEstru,{"NRINT","C",10,0})
Aadd(aEstru,{"COLONIA","C",50,0})
Aadd(aEstru,{"MUNICIPIO","C",50,0})
Aadd(aEstru,{"CODPOSTAL","C",5,0})
Aadd(aEstru,{"LOCALIDAD","C",50,0})
Aadd(aEstru,{"ESTADO","N",2,0})
Aadd(aEstru,{"TELEFONO","C",12,0})
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBusca las informaciones sobre proveedoresณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//archivo para proveedores
oTmpTbDIP := FWTemporaryTable():New(cAliasFor) 
oTmpTbDIP:SetFields( aEstru )
oTmpTbDIP:AddIndex("T1ORD1", {'CLAVE'}) 
//Creacion de la tabla
oTmpTbDIP:Create() 
DbSelectArea(cAliasFor)

If cAnexo $ "1,2"
	nTtlExerc := 0
	nTtlRelac := 0
	nTtlExter := 0
	nRelac    := 0
	nExter    := 0
	nNrConsec := 0
	SA2->(DbSetOrder(1))
	While !((cAliasSF3)->(Eof())) .And. (cAliasSF3)->F3_TIPOMOV == "C"
		cCliFor := (cAliasSF3)->F3_CLIEFOR
		cLoja   := (cAliasSF3)->F3_LOJA
		nTotal  := 0
		While !((cAliasSF3)->(Eof())) .And. (cAliasSF3)->F3_TIPOMOV == "C" .And. (cAliasSF3)->F3_CLIEFOR == cCliFor .And. (cAliasSF3)->F3_LOJA == cLoja
			nValor := Int((cAliasSF3)->F3_VALMERC)
			If !Empty(cCpoIVC)
				nValor -= Int((cAliasSF3)->&cCpoIVC)
			Endif
			If !Empty(cCpoIEP)
				nValor -= Int((cAliasSF3)->&cCpoIEP)
			Endif
			If AllTrim((cAliasSF3)->F3_ESPECIE) $ "NCP,NDE"
				nTotal -= nValor		//no se debe considerar las decimales
			Else
				nTotal += nValor		//no se debe considerar las decimales
			Endif
			(cAliasSF3)->(DbSkip())
		Enddo
		nTtlExerc += nTotal
		If nTotal >= nVlrMinimo
			SA2->(DbSeek(xFilial("SA2") + cCliFor + cLoja))
			nTtlRelac += nTotal
			If AllTrim(SA2->A2_EST) == "EX"
				nTtlExter += nTotal
			Endif
			If (SA2->A2_TIPO == "F" .And. !Empty(SA2->A2_CURP)) .Or. !Empty(SA2->A2_CGC)
				If SA2->A2_TIPO == "F"
					cChave := SA2->A2_CURP
				Else
					cChave := Padr(SA2->A2_CGC,18)
				Endif
				If !((cAliasFor)->(DbSeek(cChave)))
					nRelac++
					If AllTrim(SA2->A2_EST) == "EX"
						nExter++
					Endif
					RecLock(cAliasFor,.T.)
					nNrConsec++
					Replace (cAliasFor)->NRCONSEC	With StrZero(nNrConsec,13)
					Replace (cAliasFor)->CLAVE		With cChave
					Replace (cAliasFor)->RFC		With SA2->A2_CGC
					If SA2->A2_TIPO == "F"
						Replace (cAliasFor)->RAZON		With ""
						Replace (cAliasFor)->APELLPAT	With SA2->A2_NOMEPAT
						Replace (cAliasFor)->APELLMAT	With SA2->A2_NOMEMAT
						Replace (cAliasFor)->NOMBRE		With SA2->A2_NOMEPES
						Replace (cAliasFor)->CURP		With SA2->A2_CURP
					Else
						Replace (cAliasFor)->RAZON		With SA2->A2_NOME
						Replace (cAliasFor)->APELLPAT	With ""
						Replace (cAliasFor)->APELLMAT	With ""
						Replace (cAliasFor)->NOMBRE		With ""
						Replace (cAliasFor)->CURP		With ""
					Endif
					Replace (cAliasFor)->OPERACION	With If(SA2->A2_TPESSOA == "OS",1,0)
					Replace (cAliasFor)->CALLE		With SA2->A2_END
					Replace (cAliasFor)->NREXT		With SA2->A2_NR_END
					Replace (cAliasFor)->NRINT		With SA2->A2_NROINT
					Replace (cAliasFor)->COLONIA	With SA2->A2_BAIRRO
					Replace (cAliasFor)->MUNICIPIO	With SA2->A2_MUN
					Replace (cAliasFor)->CODPOSTAL	With AllTrim(SA2->A2_CEP)
					Replace (cAliasFor)->LOCALIDAD	With SA2->A2_MUN
					SX5->(DbSeek(xFilial("SX5") + "ES" + SA2->A2_EST))
					Replace (cAliasFor)->ESTADO		With Val(X5Descri())
					Replace (cAliasFor)->TELEFONO	With AllTrim(SA2->A2_TEL)
				Else
					RecLock(cAliasFor,.F.)
				Endif
				Replace (cAliasFor)->MONTONETO		With (cAliasFor)->MONTONETO + nTotal
				(cAliasFor)->(MsUnLock())
			Endif
		Endif
	Enddo
	_aTotal[015] := nRelac		//proveedores - numero de proveedores que relaciona
	_aTotal[016] := nTtlRelac	//proveedores - monto total de operaciones que relaciona
	_aTotal[017] := nTtlExerc	//proveedores - monto total de operaciones con proveedores en el ejercicio
	_aTotal[018] := nExter		//proveedores - numero de proveedores residentes en el extranjero
	_aTotal[019] := nTtlExter	//proveedores - monto total de operaciones con proveedores residentes en el extranjero en el ejercicio	
	(cAliasFor)->(DbGoTop())
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBusca las informaciones sobre clientesณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//archivo para clientes
oTmpTbDIC := FWTemporaryTable():New(cAliasCli) 
oTmpTbDIC:SetFields( aEstru ) //gsa
oTmpTbDIC:AddIndex("T1ORD2", {'RFC'}) 
//Creacion de la tabla
oTmpTbDIC:Create() 
DbSelectArea(cAliasCli)

If cAnexo $ "0,2"
	nTtlExerc := 0
	nTtlRelac := 0
	nTtlExter := 0
	nRelac    := 0
	nExter    := 0
	nNrConsec := 0
	SA1->(DbSetOrder(1))
	While !((cAliasSF3)->(Eof())) .And. (cAliasSF3)->F3_TIPOMOV == "V"
		cCliFor := (cAliasSF3)->F3_CLIEFOR
		cLoja   := (cAliasSF3)->F3_LOJA
		nTotal  := 0
		While !((cAliasSF3)->(Eof())) .And. (cAliasSF3)->F3_TIPOMOV == "V" .And. (cAliasSF3)->F3_CLIEFOR == cCliFor .And. (cAliasSF3)->F3_LOJA == cLoja
			nValor := Int((cAliasSF3)->F3_VALMERC)
			If !Empty(cCpoIVC)
				nValor -= Int((cAliasSF3)->&cCpoIVC)
			Endif
			If !Empty(cCpoIEP)
				nValor -= Int((cAliasSF3)->&cCpoIEP)
			Endif
			If AllTrim((cAliasSF3)->F3_ESPECIE) $ "NCC,NDI"
				nTotal -= nValor	//no se debe considerar las decimales
			Else
				nTotal += nValor	//no se debe considerar las decimales
			Endif
			(cAliasSF3)->(DbSkip())
		Enddo
		nTtlExerc += nTotal
		If nTotal >= nVlrMinimo
			nTtlRelac += nTotal
			SA1->(DbSeek(xFilial("SA1") + cCliFor + cLoja))
			If (SA1->A1_PESSOA == "F" .And. !Empty(SA1->A1_CURP)) .Or. !Empty(SA1->A1_CGC)
				If AllTrim(SA1->A1_EST) == "EX"
					nTtlExter += nTotal
				Endif
				If SA1->A1_PESSOA == "F"
					cChave := SA1->A1_CURP
				Else
					cChave := Padr(SA1->A1_CGC,18)
				Endif
				If !((cAliasCli)->(DbSeek(cChave)))
					nRelac++
					If AllTrim(SA1->A1_EST) == "EX"
						nExter++
					Endif
					RecLock(cAliasCli,.T.)
					nNrConsec++
					Replace (cAliasCLi)->NRCONSEC	With StrZero(nNrConsec,13)
					Replace (cAliasCLi)->CLAVE		With cChave
					Replace (cAliasCLi)->RFC		With SA1->A1_CGC
					If SA1->A1_PESSOA == "F"
						Replace (cAliasCLi)->RAZON		With ""
						Replace (cAliasCLi)->APELLPAT	With SA1->A1_NOMEPAT
						Replace (cAliasCLi)->APELLMAT	With SA1->A1_NOMEMAT
						Replace (cAliasCLi)->NOMBRE		With SA1->A1_NOMEPES
						Replace (cAliasCLi)->CURP		With SA1->A1_CURP
					Else
						Replace (cAliasCLi)->RAZON		With SA1->A1_NOME
						Replace (cAliasCLi)->APELLPAT	With ""
						Replace (cAliasCLi)->APELLMAT	With ""
						Replace (cAliasCLi)->NOMBRE		With ""
						Replace (cAliasCLi)->CURP		With ""
					Endif
					Replace (cAliasCLi)->OPERACION	With If(SA1->A1_TPESSOA == "OS",1,0)
					Replace (cAliasCLi)->CALLE		With SA1->A1_END
					Replace (cAliasCLi)->NREXT		With SA1->A1_NR_END
					Replace (cAliasCLi)->NRINT		With SA1->A1_NROINT
					Replace (cAliasCLi)->COLONIA	With SA1->A1_BAIRRO
					Replace (cAliasCLi)->MUNICIPIO	With SA1->A1_MUN
					Replace (cAliasCLi)->CODPOSTAL	With AllTrim(SA1->A1_CEP)
					Replace (cAliasCLi)->LOCALIDAD	With SA1->A1_MUN
					SX5->(DbSeek(xFilial("SX5") + "ES" + SA1->A1_EST))
					Replace (cAliasCli)->ESTADO		With Val(X5Descri())
					Replace (cAliasCLi)->TELEFONO	With AllTrim(SA1->A1_TEL)
				Else
					RecLock(cAliasCli,.F.)
				Endif
				Replace (cAliasCLi)->MONTONETO		With (cAliasCLi)->MONTONETO + nTotal
				(cAliasCLi)->(MsUnLock())
			Endif
		Endif
	Enddo
	_aTotal[010] := nRelac		//clientes - numero de clientes que relaciona
	_aTotal[011] := nTtlRelac	//clientes - monto total de operaciones que relaciona
	_aTotal[012] := nTtlExerc	//clientes - monto total de operaciones con clientes en el ejercicio
	_aTotal[013] := nExter		//clientes - numero de clientes residentes en el extranjero
	_aTotal[014] := nTtlExter	//clientes - monto total de operaciones con clientes residentes en el extranjero en el ejercicio
	(cAliasCli)->(DbGoTop())
Endif
#IFNDEF TOP
	RetIndex("SF3")
	cIndSF3 += OrdBagExt()
	If File(cIndSF3)
		Ferase(cIndSF3)
	EndIf
#ENDIF
RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDICPRESMEXบAutor  ณMarcello            บFecha ณ 29/10/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpresion del resumen de las informaciones de clientes y    บฑฑ
ฑฑบ          ณproveedores                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DICP - Mexico                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function DICPRESMEX(cAnexo)
Local aArea	:= {}
Local oReport

If MsgYesNo("ฟ Desea imprimir el resumen de las informaciones ?","DICP")
	aArea := GetArea()
	oReport := TReport():New("DICP","Resumen de Informaciones",,{|oReport| DICPResImp(oReport,cAnexo)},"Resumen de informaciones de clientes y proveedores") 
		oReport:SetPortrait() 
		oReport:SetTotalInLine(.F.)
	oReport:Print(.F.)
	RestArea(aArea)
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDICPRESIMPบAutor  ณMarcello            บFecha ณ 29/10/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpresion del resumen de las informaciones de clientes y    บฑฑ
ฑฑบ          ณproveedores                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DICP - Mexico                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function DICPResImp(oReport,cAnexo)
Local aRect		:= {}
Local nMeter	:= 0
Local oBrush
Local oFont

oReport:SetTitle("Resumen de la Declaraci๓n informativa de clientes y proveedores" + "  -  " + Dtoc(_aTotal[1]) + " - " + Dtoc(_aTotal[2]))
oDetalhe := TRSection():New(oReport,"Informaciones de clientes y proveedores",)
	TRCell():New(oDetalhe,"DET_TXT",,"",,160,.F.)
	TRCell():New(oDetalhe,"DET_VLR",,"",,40,.F.)
//
oFont   := TFont():New(oReport:cFontBody,,,,.T.,,.T.,,.F.,,,,,,,)
oBrush  := TBrush():New(,RGB(0,0,0))
nMeter  := 1
If cAnexo == "0"
	nMeter += 10
Else
	nMeter += 5
Endif
oReport:SetMeter(11)
oDetalhe:SetHeaderSection(.F.)
oDetalhe:Init()
oDetalhe:Cell("DET_TXT"):Hide()
oDetalhe:Cell("DET_VLR"):Hide()
oDetalhe:PrintLine()
oReport:IncRow()
oReport:IncRow()
oDetalhe:Cell("DET_TXT"):Show()
oDetalhe:Cell("DET_VLR"):Show()
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณResumen de informaciones de clientesณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
If cAnexo $ "0,2"
	oReport:Say(oReport:Row(),oDetalhe:Cell("DET_TXT"):ColPos(),"Operaciones con clientes",oFont,100)
	oReport:IncRow()
	oReport:IncRow()
	aRect := {oReport:Row(),oDetalhe:Cell("DET_TXT"):ColPos(),oReport:Row()+2,oReport:PageWidth()-2}
	oReport:FillRect(aRect,oBrush)
	oReport:IncRow()
	//numero de clientes que relaciona
	oDetalhe:Cell("DET_TXT"):SetValue("N๚mero de clientes que relaciona")
	oDetalhe:Cell("DET_VLR"):SetValue(Transform(_aTotal[10],"@E 9,999,999,999,999"))
	oDetalhe:PrintLine()
	oReport:IncRow()
	oReport:IncMeter()
	//monto total de operaciones que relaciona
	oDetalhe:Cell("DET_TXT"):SetValue("Monto total de operaciones que relaciona")
	oDetalhe:Cell("DET_VLR"):SetValue(Transform(_aTotal[11],"@E 9,999,999,999,999"))
	oDetalhe:PrintLine()
	oReport:IncRow()
	oReport:IncMeter()
	//monto total de operaciones con clientes en el ejercicio
	oDetalhe:Cell("DET_TXT"):SetValue("Monto total de operaciones con clientes en el ejercํcio")
	oDetalhe:Cell("DET_VLR"):SetValue(Transform(_aTotal[12],"@E 9,999,999,999,999"))
	oDetalhe:PrintLine()
	oReport:IncRow()
	oReport:IncMeter()
	//numero de clientes residentes en el extranjero
	oDetalhe:Cell("DET_TXT"):SetValue("N๚mero de clientes residentes en el extranjero")
	oDetalhe:Cell("DET_VLR"):SetValue(Transform(_aTotal[13],"@E 9,999,999,999,999"))
	oDetalhe:PrintLine()
	oReport:IncRow()
	//monto total de operaciones con clientes residentes en el extranjero en el ejercicio
	oDetalhe:Cell("DET_TXT"):SetValue("Monto total de operaciones con clientes residentes en el extranjero en el ejercํcio")
	oDetalhe:Cell("DET_VLR"):SetValue(Transform(_aTotal[14],"@E 9,999,999,999,999"))
	oDetalhe:PrintLine()
	oReport:IncRow()
	oReport:IncMeter()
	oReport:IncRow()
	oReport:IncRow()
	oReport:IncRow()
	oReport:IncRow()
Endif
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณResumen de informaciones de proveedoresณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
If cAnexo $ "1,2"
	oReport:Say(oReport:Row(),oDetalhe:Cell("DET_TXT"):ColPos(),"Operaciones con proveedores",oFont,100)
	oReport:IncRow()
	oReport:IncRow()
	aRect := {oReport:Row(),oDetalhe:Cell("DET_TXT"):ColPos(),oReport:Row()+2,oReport:PageWidth()-2}
	oReport:FillRect(aRect,oBrush)
	oReport:IncRow()
	//Numero de Proveedores de Bienes y Servicios que Relaciona
	oDetalhe:Cell("DET_TXT"):SetValue("N๚mero de proveedores de bienes y servํcios que relaciona")
	oDetalhe:Cell("DET_VLR"):SetValue(Transform(_aTotal[15],"@E 9,999,999,999,999"))
	oDetalhe:PrintLine()
	oReport:IncRow()
	oReport:IncMeter()
	//monto total de operaciones que relaciona
	oDetalhe:Cell("DET_TXT"):SetValue("Monto total de operaciones que relaciona")
	oDetalhe:Cell("DET_VLR"):SetValue(Transform(_aTotal[16],"@E 9,999,999,999,999"))
	oDetalhe:PrintLine()
	oReport:IncRow()
	oReport:IncMeter()
	//Monto total de Operaciones Con Proveedores de Bienes y Servicios en el Ejercicio
	oDetalhe:Cell("DET_TXT"):SetValue("Monto total de operaciones con proveedores de bienes y servํcios en el ejercํcio")
	oDetalhe:Cell("DET_VLR"):SetValue(Transform(_aTotal[17],"@E 9,999,999,999,999"))
	oDetalhe:PrintLine()
	oReport:IncRow()
	oReport:IncMeter()
	//Numero de Proveedores de Bienes y Servicios Residentes en el Extranjero
	oDetalhe:Cell("DET_TXT"):SetValue("N๚mero de proveedores de bienes y servํcios residentes en el extranjero")
	oDetalhe:Cell("DET_VLR"):SetValue(Transform(_aTotal[18],"@E 9,999,999,999,999"))
	oDetalhe:PrintLine()
	oReport:IncRow()
	//Monto Total de Operaciones con Proveedores de Bienes y Servicios residentes en el extranjero en el Ejercicio
	oDetalhe:Cell("DET_TXT"):SetValue("Monto total de operaciones con proveedores de bienes y servํcios residentes en el extranjero en el ejercํcio")
	oDetalhe:Cell("DET_VLR"):SetValue(Transform(_aTotal[19],"@E 9,999,999,999,999"))
	oDetalhe:PrintLine()
	oReport:IncRow()
	oReport:IncMeter()
Endif
//
oReport:IncMeter()
oDetalhe:Finish()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDICPVALMEXบAutor  ณMarcello            บFecha ณ 29/10/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpresion del report para validacion de la generacion del   บฑฑ
ฑฑบ          ณarchivo para DICP                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DICP - Mexico                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function DICPValMex()
Local aArea := {}
Local oReport

If MsgYesNo("ฟ Desea imprimir el reporte para validaci๓n de las informaciones ?","DICP")
	aArea := GetArea()
	oReport := TReport():New("DICP","Reporte de validaci๓n de las Informaciones",,{|oReport| DICPValImp(oReport)},"Reporte para validaci๓n de las informaciones generadas") 
		oReport:SetLandscape() 
		oReport:SetTotalInLine(.F.)
	oReport:PrintDialog()
	RestArea(aArea)
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDICPVALIMPบAutor  ณMarcello            บFecha ณ 29/10/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpresion del report para validacion de la generacion del   บฑฑ
ฑฑบ          ณarchivo para DICP                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ DICP - Mexico                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function DICPValImp(oReport)
Local nLin		:= 0
Local nAltPag	:= 0

oReport:SetTitle("Reporte de las informaciones generadas para DICP" + "  -  " + Dtoc(_aTotal[1]) + " - " + Dtoc(_aTotal[2]))
oDetalhe := TRSection():New(oReport,"Informaciones de clientes y proveedores",)
	TRCell():New(oDetalhe,"DET_TIPO",,RetTitle("F3_CLIEFOR"),,15,.F.)
	TRCell():New(oDetalhe,"DET_RFC",,RetTitle("A1_CGC"),,25,.F.)
	TRCell():New(oDetalhe,"DET_CURP",,RetTitle("A1_CURP"),,35,.F.)
	TRCell():New(oDetalhe,"DET_RAZON",,RetTitle("A1_NOME"),,27,.F.)
	TRCell():New(oDetalhe,"DET_APELLPAT",,RetTitle("A1_NOMEPAT"),,25,.F.)
	TRCell():New(oDetalhe,"DET_APELLMAT",,RetTitle("A1_NOMEMAT"),,25,.F.)
	TRCell():New(oDetalhe,"DET_NOMEPES",,"Nombre",,27,.F.)
	TRCell():New(oDetalhe,"DET_MONTONETO",,"Total","@E 9,999,999,999,999",15,.F.)
	TRCell():New(oDetalhe,"DET_OPERACION",,"Oper.",,5,.F.)
	TRCell():New(oDetalhe,"DET_CALLE",,RetTitle("A1_END"),,20,.F.)
	TRCell():New(oDetalhe,"DET_NREXT",,"Nr. Ext",,10,.F.)
	TRCell():New(oDetalhe,"DET_NRINT",,"Nr. Int",,15,.F.)
	TRCell():New(oDetalhe,"DET_COLONIA",,RetTitle("A1_BAIRRO"),,20,.F.)
	TRCell():New(oDetalhe,"DET_MUNICIPIO",,RetTitle("A1_MUN"),,25,.F.)
	TRCell():New(oDetalhe,"DET_CODPOSTAL",,RetTitle("A1_CEP"),,10,.F.)
	TRCell():New(oDetalhe,"DET_LOCALIDAD",,"Localidad",,25,.F.)
	TRCell():New(oDetalhe,"DET_ESTADO",,RetTitle("A1_EST"),,5,.F.)
//	TRCell():New(oDetalhe,"DET_TELEFONO",,RetTitle("A1_TEL"),,10,.F.)
//
nAltPag := oReport:PageHeight() - 2
nLin := 0
oReport:SetMeter(DIC->(RecCount()) + DIP->(RecCount()) + 1)
oDetalhe:Init()
//Clientes
DIC->(DbGoTop())
oDetalhe:Cell("DET_TIPO"):SetValue("Cliente")
oDetalhe:cell("DET_TIPO"):Show()
While !oReport:Cancel() .And. !DIC->(Eof())
	oDetalhe:Cell("DET_RFC"):SetValue(DIC->RFC)
	oDetalhe:Cell("DET_CURP"):SetValue(DIC->CURP)
	oDetalhe:Cell("DET_RAZON"):SetValue(DIC->RAZON)
	oDetalhe:Cell("DET_APELLPAT"):SetValue(DIC->APELLPAT)
	oDetalhe:Cell("DET_APELLMAT"):SetValue(DIC->APELLMAT)
	oDetalhe:Cell("DET_NOMEPES"):SetValue(DIC->NOMBRE)
	oDetalhe:Cell("DET_MONTONETO"):SetValue(DIC->MONTONETO)
	oDetalhe:Cell("DET_OPERACION"):SetValue(DIC->OPERACION)
	oDetalhe:Cell("DET_CALLE"):SetValue(DIC->CALLE)
	oDetalhe:Cell("DET_NREXT"):SetValue(DIC->NREXT)
	oDetalhe:Cell("DET_NRINT"):SetValue(DIC->NRINT)
	oDetalhe:Cell("DET_COLONIA"):SetValue(DIC->COLONIA)
	oDetalhe:Cell("DET_MUNICIPIO"):SetValue(DIC->MUNICIPIO)
	oDetalhe:cell("DET_CODPOSTAL"):SetValue(DIC->CODPOSTAL)
	oDetalhe:Cell("DET_LOCALIDAD"):SetValue(DIC->LOCALIDAD)
	oDetalhe:Cell("DET_ESTADO"):SetValue(DIC->ESTADO)
//	oDetalhe:Cell("DET_TELEFONO"):SetValue(DIC->TELEFONO)
	oDetalhe:PrintLine()
	oDetalhe:cell("DET_TIPO"):Hide()
	nLin := oReport:Row()
	If nLin >= nAltPag
		oReport:EndPage()
		oDetalhe:Init()
		oDetalhe:cell("DET_TIPO"):Show()
	Endif
	DIC->(DbSkip())
	oReport:IncMeter()
Enddo
//Fornecedores
DIP->(DbGoTop())
oDetalhe:Cell("DET_TIPO"):SetValue("Proveedor")
oDetalhe:Cell("DET_TIPO"):Show()
While !oReport:Cancel() .And. !DIP->(Eof())
	oDetalhe:Cell("DET_RFC"):SetValue(DIP->RFC)
	oDetalhe:Cell("DET_CURP"):SetValue(DIP->CURP)
	oDetalhe:Cell("DET_RAZON"):SetValue(DIP->RAZON)
	oDetalhe:Cell("DET_APELLPAT"):SetValue(DIP->APELLPAT)
	oDetalhe:Cell("DET_APELLMAT"):SetValue(DIP->APELLMAT)
	oDetalhe:Cell("DET_NOMEPES"):SetValue(DIP->NOMBRE)
	oDetalhe:Cell("DET_MONTONETO"):SetValue(DIP->MONTONETO)
	oDetalhe:Cell("DET_OPERACION"):SetValue(DIP->OPERACION)
	oDetalhe:Cell("DET_CALLE"):SetValue(DIP->CALLE)
	oDetalhe:Cell("DET_NREXT"):SetValue(DIP->NREXT)
	oDetalhe:Cell("DET_NRINT"):SetValue(DIP->NRINT)
	oDetalhe:Cell("DET_COLONIA"):SetValue(DIP->COLONIA)
	oDetalhe:Cell("DET_MUNICIPIO"):SetValue(DIP->MUNICIPIO)
	oDetalhe:cell("DET_CODPOSTAL"):SetValue(DIP->CODPOSTAL)
	oDetalhe:Cell("DET_LOCALIDAD"):SetValue(DIP->LOCALIDAD)
	oDetalhe:Cell("DET_ESTADO"):SetValue(DIP->ESTADO)
//	oDetalhe:Cell("DET_TELEFONO"):SetValue(DIP->TELEFONO)
	oDetalhe:PrintLine()
	oDetalhe:cell("DET_TIPO"):Hide()
	nLin := oReport:Row()
	If nLin >= nAltPag
		oReport:EndPage()
		oDetalhe:Init()
		oDetalhe:cell("DET_TIPO"):Show()
	Endif
	DIP->(DbSkip())
	oReport:IncMeter()
Enddo
//
oReport:IncMeter()
//oReport:Finish()
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณDICPDel   ณAutor  ณALfredo medrano     ณFecha ณ 04/01/2017    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDesc.     ณBorra los archivos temporales procesados.                     ณฑฑ
ฑฑณ          ณ                                                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณDICPDel - Mexico                                              ณฑฑ   
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function DICPDel()
Local aAreaDel := GetArea()

If oTmpTbDIP <> Nil  
	oTmpTbDIP:Delete() 
	oTmpTbDIP := Nil 
Endif

If oTmpTbDIC <> Nil  
	oTmpTbDIC:Delete() 
	oTmpTbDIC := Nil 
Endif

RestArea(aAreaDel)
Return
