#Include 'Protheus.ch'
#Include 'plsa264.ch'

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSA271
Retorna os dados do beneficiario de acordo com a RN 389

@author	Lucas Nonato
@since		06/12/2016
@version	P12

/*/
//---------------------------------------------------------------------------------------
Function PLSA271( cMatric )

	Local cDataNasc   	:= ""
	Local cDataInsc   	:= ""
	Local cDatXInsc 	:= ""
	Local cDataValid  	:= ""
	Local aStruc      	:= {}
	Local aRetNome    	:= {}
	Local lErro       	:= .F.
	Local dDatCpt
	Local cNomTit
	LOCAL aCriticas   	:= {}
	local aDados		:= {}
	LOCAL cUniver     	:= ""
	Local lNomCar		:= .F.
	Local lTpCtrBI3		:= (GetNewPar("MV_PLTPBI3","0")=="1") .AND. BII->(FieldPos("BII_TIPPLA")) > 0 // Verifica se busca o tipo de plano SIP pelo BI3 ou continua pelo BT5
	Local cTipPlan 		:= ''
	Local cNumPlan 		:= ''
	Local cDTContrat 	:= ''
	Local dMaxCarenc 	:= CtoD( "  /  /  " )
	Local nCont
	local lBDENom		:= BDE->(FieldPos("BDE_NOMCAR")) > 0
	local lTpBDENom		:= .f.

	//RN-360
	//Tarja magnetica...
	Aadd(aStruc,{"TARJAMAG1"	,"C",34,0})
	Aadd(aStruc,{"TARJAMAG2"	,"C",30,0})

	//Frente do Cartao...
	Aadd(aStruc,{"NOMEUSUARI"  	,"C",30,0}) //nome do beneficiario
	Aadd(aStruc,{"MATRICULA"   	,"C",21,0}) //numero da matricula
	Aadd(aStruc,{"DTNACTO"     	,"C",10,0}) //data de ascimento do beneficiario
	Aadd(aStruc,{"DTVALID"     	,"C",10,0}) //data de ascimento do beneficiario
	Aadd(aStruc,{"DTINC"		,"C",10,0})
	Aadd(aStruc,{"PLANO"		,"C",04,0})
	Aadd(aStruc,{"TPCONTRATO"   ,"C",04,0})
	Aadd(aStruc,{"CNESUSU"	    ,"C",15,0}) //numero do cartao naciona de saude CNS
	Aadd(aStruc,{"SUSEP"	    ,"C",12,0}) //numero do registro do plano ou do cad. do plano na ans
	Aadd(aStruc,{"SEGASSPL"     ,"C",56,0}) //segmentacao assistencial do plano
	Aadd(aStruc,{"NUMREGOPE"    ,"C",6,0}) 	//codigo do registro da operadora na ans - BA0_SUSEP //BA0_FILIAL+BA0_CODIDE+BA0_CODINT
	Aadd(aStruc,{"CONTATOOPE"   ,"C",800,0}) //informacao de contato com a operadora - BIM_NOME-BIM_TELCON-BIM_EMAIL (Quando setor == 012 BIM_SETOR) //BIM_FILIAL+BIM_CODINT+BIM_CODIGO
	Aadd(aStruc,{"CONTATOANS"   ,"C",800,0}) //informacao de contato com a ans - BK5_NOME-BK5_TEL-BK5_EMAIL //BK5_FILIAL+BK5_NOME
	Aadd(aStruc,{"CPT"    		,"C",10,0})  //data de termino da cobertura parcial temporaria

	//Verso do Cartao...
	Aadd(aStruc,{"TPACOMODA"	,"C",100,0})  //padrao de acomodacao
	Aadd(aStruc,{"CONTRATACA"  	,"C",30,0})  //tipo de contratacao
	Aadd(aStruc,{"ABRANG"  		,"C",19,0})  //area de abrangencia geografica
	Aadd(aStruc,{"NOMPRO"		,"C",22,0})	 //nome do produto
	Aadd(aStruc,{"NFANTAZOPE"   ,"C",60,0})	 //nome fantasia da operadora - BA0_NOMINT
	Aadd(aStruc,{"NFAADMBENE"   ,"C",40,0})	 //nome fantasia da administradora de beneficios - BG9_NREDUZ
	Aadd(aStruc,{"RZSOCIAL"     ,"C",40,0})  //nome da p. juridica contratante do plano coletivo ou emp.
	Aadd(aStruc,{"DTVIGPL"  	,"C",10,0})  //data de inicio da vigencia do plano
	Aadd(aStruc,{"NUMCON"  		,"C",20,0})  //Numero do contrato apólice
	Aadd(aStruc,{"DATCON"  		,"C",10,0})  //Data de contratação do plano de saúde
	Aadd(aStruc,{"DTMAXCON"  	,"C",10,0})  //Prazo máximo previsto no contrato para carência
	Aadd(aStruc,{"INFOPLAN"  	,"C",50,0})  //Informação sobre a regulamentação do plano
	Aadd(aStruc,{"INFORMACOE"   ,"C",11,0})  //informacoes
	Aadd(aStruc,{"CARENCAMB"   ,"C",20,0})  //Carência Procedimentos Ambulatorias
	Aadd(aStruc,{"CARENCHOS"   ,"C",20,0})  //Carência Procedimentos Hospitalares
	Aadd(aStruc,{"CARENCPAT"   ,"C",20,0})  //Carência Procedimentos Parto a Termo
	Aadd(aStruc,{"CARENCODO"   ,"C",20,0})  //Carência Procedimentos Odontológicos


	oTempTable := FWTemporaryTable():New( "Dados" )
	oTemptable:SetFields( aStruc )
	oTempTable:AddIndex( "indice1",{ "MATRICULA" } )
	oTempTable:Create()

	BQC->(DbSetOrder(1))
	BF3->(dbSetOrder(1))
	BI3->(dbSetOrder(1))
	BDL->(DbSetOrder(1))
	BA1->(DbSetOrder(2))
	BA3->(DbSetOrder(1))
	BTS->(DbSetOrder(1))

	If BA1->(DbSeek(xFilial("BA1")+cMatric))

		If BA3->(DbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))

			If BTS->(DbSeek(xFilial("BTS")+BA1->(BA1_MATVID)))

				//³ Verifica Regulamentação do Plano                                    ³
				If BI3->(msSeek(xFilial("BF3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))

					Do Case
						Case BI3->BI3_APOSRG == '0'
							cTipPlan := 'Plano Nao Regulamentado'
						Case BI3->BI3_APOSRG == '1'
							cTipPlan := 'Plano Regulamentado'
						Case BI3->BI3_APOSRG == '2'
							cTipPlan := 'Plano Adaptado'
					EndCase
				Endif
				//³ Verifica Prazo Maximo de carencia                                   ³
				aVetCarenc := {}
				aRetCarenc := PLSCLACAR(BA1->BA1_CODINT,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),/*dDataBase*/)

				If Len(aRetCarenc) > 0 .And. aRetCarenc[1]
					dMaxCarenc := aRetCarenc[2][1][3]
					For nCont := 1 to len(aRetCarenc[2])
						If Len(aRetCarenc[2][nCont]) > 7
							If aRetCarenc[2][nCont][3] > dMaxCarenc
								dMaxCarenc := aRetCarenc[2][nCont][3]
							Endif
						Endif
					Next
				Endif

				If BA3->BA3_TIPOUS <> "1"
					If  BT5->(BT5_FILIAL+BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO) <>  xFilial("BT5")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)
						BT5->(DbSetOrder(1))
						BT5->(msSeek(xFilial("BT5")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)))
					Endif

					If  BQC->(BQC_FILIAL+BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB) <> xFilial("BQC")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)
						BQC->(DbSetOrder(1))
						BQC->(msSeek(xFilial("BQC")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
					Endif

				Endif

				If  BG9->(BG9_FILIAL+BG9_CODINT+BG9_CODIGO) <> xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP)
					BG9->(DbSetOrder(1))
					BG9->(msSeek(xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP)))
				Endif


				cNomTit := BTS->BTS_NOMCAR
				cUniver := BTS->BTS_UNIVER


				dDtVali := BA1->BA1_DTVLCR
				nViaCar := BA1->BA1_VIACAR

				//³ LayOut PLS... 						                                ³
				cDataNasc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATNAS),2), cMes := StrZero(Month(BA1->BA1_DATNAS),2), cAno := StrZero(Year(BA1->BA1_DATNAS),4), cDia+"/"+cMes+"/"+cAno })
				cDataInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })
				cDataValid:= Eval({ || cDia := StrZero(Day(dDtVali),2), cMes := StrZero(Month(dDtVali),2), cAno := StrZero(Year(dDtVali),4), cDia+"/"+cMes+"/"+cAno })
				cDatXInsc := Eval({ || cDia := StrZero(Day(BA1->BA1_DATINC),2), cMes := StrZero(Month(BA1->BA1_DATINC),2), cAno := StrZero(Year(BA1->BA1_DATINC),4), cDia+"/"+cMes+"/"+cAno })

				aRetNome:= PLSAVERNIV(	BA1->BA1_CODINT, BA1->BA1_CODEMP, BA1->BA1_MATRIC,	IF(BA3->BA3_TIPOUS=="1","F","J"),BA3->BA3_CONEMP, BA3->BA3_VERCON, BA3->BA3_SUBCON, BA3->BA3_VERSUB, 1,	BA1->BA1_TIPREG)

				//³ Alimenta arquivo com os dados para arquivo texto...			³
				Dados->(RecLock("Dados",.T.))

				//³ LayOut PLS... 						                                ³
				Dados->TARJAMAG1 :=	BA1->BA1_CODINT+;
					BA1->BA1_CODEMP+;
					BA1->BA1_MATRIC+;
					BA1->BA1_TIPREG+;
					BA1->BA1_DIGITO+;
					"="+; //Campo separador.
					Strzero(nViaCar,2)+;
					SubStr(cDataValid,9,2)+SubStr(cDataValid,4,2)+;
					"="+; //Campo separador
					BA1->BA1_OPERES+;
					BI3->BI3_IDECAR+; //Codigo do produto no Intercambio
					SubStr(BI3->BI3_ABRANG,Len(BI3->BI3_ABRANG),1)+;
					BA3->BA3_TIPCON
				Dados->TARJAMAG2 := BTS->BTS_NOMCAR	

				Dados->MATRICULA := BA1->BA1_CODINT + BA1->BA1_CODEMP + BA1->BA1_MATRIC + BA1->BA1_TIPREG + BA1->BA1_DIGITO

				Dados->DATCON		:= cDTContrat
				Dados->INFOPLAN 	:= cTipPlan

				If  BA3->BA3_TIPOUS <> "1" .and. !Empty(BQC->BQC_NOMCAR)
					Dados->RZSOCIAL   := BQC->BQC_NOMCAR
				Else
					Dados->RZSOCIAL   := aRetNome[1][3]
				Endif

				aDadUsr := PLSDADUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),"1",.F.,dDataBase)

				// Classes de Carencia
				If BDL->( msSeek(xFilial("BDL")+BA1->BA1_CODINT+Alltrim(GetNewPar("MV_PLCLAMB","XXX"))) )
					aNivCar := PlsClasCar({BDL->BDL_UNCAR,BDL->BDL_CARENC,"1",BDL->BDL_CODIGO,BDL->BDL_CODINT,BA1->BA1_DATCAR,.F.},	aDadUsr,'','',BA1->BA1_CODINT,BA3->BA3_CODPLA,BA3->BA3_VERSAO)
					/*
					[1] = Unidade de contagem da carencia
					[2] = Quantidade de carencia da unidade acima
					[3] = Nivel da Classe de Carencia
					[4] = Classe da carencia informada
					[5] = Codigo da Operadora
					[6] = Data base de carencia
					*/

					If aNivCar[1] == "1" //1=Horas;2=Dias;3=Meses;4=Anos
						cDesUnCar := "Horas"
					ElseIf aNivCar[1] == "2"
						cDesUnCar := "Dias"
					ElseIf aNivCar[1] == "3"
						cDesUnCar := "Meses"
					ElseIf aNivCar[1] == "4"
						cDesUnCar := "Anos"
					Else
						cDesUnCar :=""
					Endif

					//Deverá exibir carencia do beneficiário e não do codigo da carencia

					If Len(aNivCar) >= 7  .and. aNivCar[7]
						Dados->CARENCAMB := Alltrim(Str(aNivCar[2])) + " "+cDesUnCar
					Else
						Dados->CARENCAMB := ""
					Endif
				ELse
					Dados->CARENCAMB := ""
				Endif

				If BDL->( msSeek(xFilial("BDL")+BA1->BA1_CODINT+Alltrim(GetNewPar("MV_PLCLHOS","XXX"))) )

					aNivCar := PlsClasCar({BDL->BDL_UNCAR,BDL->BDL_CARENC,"1",BDL->BDL_CODIGO,BDL->BDL_CODINT,BA1->BA1_DATCAR,.F.},	aDadUsr,'','',BA1->BA1_CODINT,BA3->BA3_CODPLA,BA3->BA3_VERSAO)
					/*
					[1] = Unidade de contagem da carencia
					[2] = Quantidade de carencia da unidade acima
					[3] = Nivel da Classe de Carencia
					[4] = Classe da carencia informada
					[5] = Codigo da Operadora
					[6] = Data base de carencia
					*/
					If aNivCar[1] == "1" //1=Horas;2=Dias;3=Meses;4=Anos
						cDesUnCar := "Horas"
					ElseIf aNivCar[1] == "2"
						cDesUnCar := "Dias"
					ElseIf aNivCar[1] == "3"
						cDesUnCar := "Meses"
					ElseIf aNivCar[1] == "4"
						cDesUnCar := "Anos"
					Else
						cDesUnCar :=""
					Endif

					//Deverá exibir carencia do beneficiário e não do codigo da carencia
					If Len(aNivCar) >= 7  .and. aNivCar[7]
						Dados->CARENCHOS := Alltrim(Str(aNivCar[2]))+ " "+cDesUnCar
					Else
						Dados->CARENCHOS := ""
					Endif
				ELse
					Dados->CARENCHOS := ""
				Endif

				If BDL->( msSeek(xFilial("BDL")+BA1->BA1_CODINT+Alltrim(GetNewPar("MV_PLCLPAT","XXX"))) )

					aNivCar := PlsClasCar({BDL->BDL_UNCAR,BDL->BDL_CARENC,"1",BDL->BDL_CODIGO,BDL->BDL_CODINT,BA1->BA1_DATCAR,.F.},	aDadUsr,'','',BA1->BA1_CODINT,BA3->BA3_CODPLA,BA3->BA3_VERSAO)

					If aNivCar[1] == "1" //1=Horas;2=Dias;3=Meses;4=Anos
						cDesUnCar := "Horas"
					ElseIf aNivCar[1] == "2"
						cDesUnCar := "Dias"
					ElseIf aNivCar[1] == "3"
						cDesUnCar := "Meses"
					ElseIf aNivCar[1] == "4"
						cDesUnCar := "Anos"
					Else
						cDesUnCar :=""
					Endif

					//Deverá exibir carencia do beneficiário e não do codigo da carencia
					If Len(aNivCar) >= 7  .and. aNivCar[7]
						Dados->CARENCPAT := Alltrim(Str(aNivCar[2]))+ " "+cDesUnCar
					Else
						Dados->CARENCPAT := ""
					Endif
				ELse
					Dados->CARENCPAT := ""
				Endif

				If BDL->( msSeek(xFilial("BDL")+BA1->BA1_CODINT+Alltrim(GetNewPar("MV_PLCLODO","XXX"))) )

					aNivCar := PlsClasCar({BDL->BDL_UNCAR,BDL->BDL_CARENC,"1",BDL->BDL_CODIGO,BDL->BDL_CODINT,BA1->BA1_DATCAR,.F.},	aDadUsr,'','',BA1->BA1_CODINT,BA3->BA3_CODPLA,BA3->BA3_VERSAO)

					If aNivCar[1] == "1" //1=Horas;2=Dias;3=Meses;4=Anos
						cDesUnCar := "Horas"
					ElseIf aNivCar[1] == "2"
						cDesUnCar := "Dias"
					ElseIf aNivCar[1] == "3"
						cDesUnCar := "Meses"
					ElseIf aNivCar[1] == "4"
						cDesUnCar := "Anos"
					Else
						cDesUnCar :=""
					Endif

					//Deverá exibir carencia do beneficiário e não do codigo da carencia
					If Len(aNivCar) >= 7  .and. aNivCar[7]
						Dados->CARENCODO := Alltrim(Str(aNivCar[2]))+ " "+cDesUnCar
					Else
						Dados->CARENCODO := ""
					Endif
				ELse
					Dados->CARENCODO := ""
				Endif

				Dados->INFORMACOE := STR0055 //"Informações"
				Dados->CNESUSU	 :=  AllTrim(BTS->BTS_NRCRNA)
				Dados->SEGASSPL  :=  padr(substr(POSICIONE("BI6",1,XFILIAL("BI6")+ BI3->BI3_CODSEG,"BI6_DESCRI"),1,56),56)

				BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
				BA0->( msSeek(xFilial("BA0")+BA1->BA1_CODINT) )

				If BA0->( Fieldpos("BA0_AUTGES") ) > 0 .And.  BA0->BA0_AUTGES == '0'
					cNumPlan := BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)
				Else
					cNumPlan := BI3->BI3_SUSEP
				EndIf

				Dados->NUMCON		:= cNumPlan
				Dados->NUMREGOPE  := BA0->BA0_SUSEP
				Dados->NFANTAZOPE := BA0->BA0_NOMINT

				BMV->(DbSetOrder(1))//BMV_FILIAL+BMV_CODIGO
				If BMV->( MsSeek(xFilial("BMV")+"STR0019") )
					Dados->CONTATOANS := AllTrim(BMV->BMV_MSGPOR)
				Else
					Dados->CONTATOANS := ""
				Endif

				If BMV->( MsSeek(xFilial("BMV")+"STR0020") )
					Dados->CONTATOOPE := AllTrim(BMV->BMV_MSGPOR)
				Else
					Dados->CONTATOOPE := ""
				Endif

				Dados->CPT        := IIF(empty(dDatCpt),PadR('',12),substr(dtos(dDatCpt),7,2)+"/"+substr(dtos(dDatCpt),5,2)+"/"+substr(dtos(dDatCpt),1,4))

				BG9->(DbSetOrder(1))//BG9_FILIAL+BG9_CODINT+BG9_CODIGO+BG9_TIPO
				BG9->( msSeek( xFilial("BG9")+BA1->(BA1_CODINT+BA1_CODEMP) ) )

				Dados->NFAADMBENE := BG9->BG9_NREDUZ
				Dados->DTNACTO    := cDataNasc

				If  BA3->BA3_TIPOUS == "1"
					Do Case
						Case BI3->BI3_NATJCO = "2"
							Dados->CONTRATACA := 'INDIVIDUAL OU FAMILIAR'
						Case BI3->BI3_NATJCO = "3"
							Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
						Case BI3->BI3_NATJCO = "4"
							Dados->CONTRATACA := 'COLETIVO POR ADESAO'
						Case BI3->BI3_NATJCO = "5"
							Dados->CONTRATACA := 'BENEFICIENTE'
						Otherwise
							Dados->CONTRATACA := "SEM CONTRATACAO"
					EndCase
				Else
					If  AllTrim(BQC->BQC_ENTFIL) == "1"
						Dados->CONTRATACA := 'BENEFICIENTE'
					Else
						BII->(DbSetOrder(1))
						If lTpCtrBI3 .AND. BII->( msSeek(xFilial("BII")+BI3->BI3_TIPCON) )
							Do Case
								Case AllTrim(BII->BII_TIPPLA) == "1"
									Dados->CONTRATACA := 'INDIVIDUAL OU FAMILIAR'
								Case AllTrim(BII->BII_TIPPLA) == "2"
									Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'

								Case AllTrim(BII->BII_TIPPLA) == "3"
									Dados->CONTRATACA := 'COLETIVO POR ADESAO'
								Otherwise
									Dados->CONTRATACA := "SEM CONTRATACAO"
							EndCase
						Else
							If BII->( msSeek(xFilial("BII")+BT5->BT5_TIPCON) )
								Do Case
									Case AllTrim(BII->BII_TIPPLA) == "1"
										Dados->CONTRATACA := 'INDIVIDUAL OU FAMILIAR'

									Case AllTrim(BII->BII_TIPPLA) == "2"
										Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'

									Case AllTrim(BII->BII_TIPPLA) == "3"
										Dados->CONTRATACA := 'COLETIVO POR ADESAO'

									Otherwise
										Dados->CONTRATACA := "SEM CONTRATACAO"
								EndCase
							Endif
						EndIf
					Endif
				Endif

				cTpAcomod := PLSGETVINC("BTQ_DESTER", "BI4",.F.,"49",PLSGETVINC("BTU_CDTERM", "BI4", .F., "49",AllTrim(BI3->BI3_CODACO),.F. ),.F.)

				Dados->TPACOMODA := cTpAcomod

				lTpBDENom := TYPE( "M->BDE_NOMCAR" ) <> "U"

				If lBDENom .And. lTpBDENom
					If M->BDE_NOMCAR == "1"
						Dados->NOMEUSUARI := PadR(BTS->BTS_NOMCAR,25)
					Else
						Dados->NOMEUSUARI := PadR(BTS->BTS_NOMUSR,25)
					EndIf
				Else
					Dados->NOMEUSUARI := BTS->BTS_NOMCAR
				EndIF

				Dados->ABRANG := Posicione("BF7",1,xFilial("BF7")+BI3->BI3_ABRANG,"BF7_DESORI")

				Dados->DTVIGPL 	:= cDatXInsc
				Dados->NOMPRO   := BI3->BI3_NREDUZ
				Dados->SUSEP 	:= Iif(BI3->BI3_APOSRG == "1",BI3->BI3_SUSEP,BI3->BI3_SCPA)
				Dados->(MsUnlock())


				BED->(DbSetOrder(4))
				BED->(msSeek(xFilial("BED")+BDE->BDE_CODIGO))

				While xFilial("BED") == BED->BED_FILIAL .and. BDE->BDE_CODIGO == BED->BED_CDIDEN .and. ! BED->(Eof())

					lErro := .F.

					If lBDENom 
						lNomCar := (BED->BED_NOMCAR == "1")
					EndIf

					If  BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC) <> ;
							xFilial("BA3")+BED->(BED_CODINT+BED_CODEMP+BED_MATRIC)
						BA3->(DbSetOrder(1))
						BA3->(msSeek(xFilial("BA3")+BED->BED_CODINT+BED->BED_CODEMP+BED->BED_MATRIC))
					Endif
					If BA3->BA3_TIPOUS <> "1"

						If  BT5->(BT5_FILIAL+BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO) <> xFilial("BT5")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)
							BT5->(DbSetOrder(1))
							BT5->(msSeek(xFilial("BT5")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)))
							If  ! BT5->(Found()) .and. ! lErro
								Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0013}) //"Contrato não Cadastrado."
								lErro := .T.
							Endif
						Endif

						If  BQC->(BQC_FILIAL+BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB) <> xFilial("BQC")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)
							BQC->(DbSetOrder(1))
							BQC->(msSeek(xFilial("BQC")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
							If  ! BQC->(Found()) .and. ! lErro
								Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0014}) //"Sub-Contrato não Cadastrado."
								lErro := .T.
							Endif
						Endif

						If  BQC->BQC_EMICAR == "0"
							Aadd(aCriticas, {BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),STR0025}) //"Via do cartao inválida. "
							lErro := .T.
						Endif
					Endif

					If  BG9->(BG9_FILIAL+BG9_CODINT+BG9_CODIGO) <> ;
							xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP)
						BG9->(DbSetOrder(1))
						BG9->(msSeek(xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP)))
					Endif


					If lBDENom
						If BDE->BDE_NOMCAR == "1" .Or. lNomCar
							cNomTit := BTS->BTS_NOMCAR
						Else
							cNomTit := BTS->BTS_NOMUSR
						EndIf
					Else
						cNomTit := BTS->BTS_NOMCAR
					EndIf

					Dados->(RecLock("Dados",.T.))
					Dados->TARJAMAG1 :=	BA1->BA1_CODINT+;
						BA1->BA1_CODEMP+;
						BA1->BA1_MATRIC+;
						BA1->BA1_TIPREG+;
						BA1->BA1_DIGITO+;
						"="+; //Campo separador
						Strzero(BED->BED_VIACAR,2)+;
						SubStr(cDataValid,9,2)+SubStr(cDataValid,4,2)+;
						"="+; //Campo separador
						BA1->BA1_OPERES+;
						BI3->BI3_IDECAR+; //Codigo do produto no Intercambio
						SubStr(BI3->BI3_ABRANG,Len(BI3->BI3_ABRANG),1)+;
						BA3->BA3_TIPCON

					if lBDENom .And. lTpBDENom
						if M->BDE_NOMCAR == "1"
							Dados->TARJAMAG2 := BTS->BTS_NOMCAR
						else
							Dados->TARJAMAG2 := BTS->BTS_NOMUSR
						endIf
					else
						Dados->TARJAMAG2 := BTS->BTS_NOMCAR
					endIf

					Dados->MATRICULA := BA1->BA1_CODINT + ;
						BA1->BA1_CODEMP + ;
						BA1->BA1_MATRIC + ;
						BA1->BA1_TIPREG + ;
						BA1->BA1_DIGITO

					If  BA3->BA3_TIPOUS <> "1" .and. !Empty(BQC->BQC_NOMCAR)
						Dados->RZSOCIAL   := BQC->BQC_NOMCAR
					Else
						Dados->RZSOCIAL   := aRetNome[1][3]
					Endif

					// Classes de Carencia
					BDL->(DbSetOrder(1))
					If BDL->( msSeek(xFilial("BDL")+BA1->BA1_CODINT+Alltrim(GetNewPar("MV_PLCLAMB","XXX"))) )

						aNivCar := PlsClasCar({BDL->BDL_UNCAR,BDL->BDL_CARENC,"1",BDL->BDL_CODIGO,BDL->BDL_CODINT,BA1->BA1_DATCAR,.F.},;
							aDadUsr,'','',BA1->BA1_CODINT,BA3->BA3_CODPLA,BA3->BA3_VERSAO)

						If aNivCar[1] == "1" //1=Horas;2=Dias;3=Meses;4=Anos
							cDesUnCar := "Horas"
						ElseIf aNivCar[1] == "2"
							cDesUnCar := "Dias"
						ElseIf aNivCar[1] == "3"
							cDesUnCar := "Meses"
						ElseIf aNivCar[1] == "4"
							cDesUnCar := "Anos"
						Else
							cDesUnCar :=""
						Endif

						If Len(aNivCar) >= 7  .and. aNivCar[7]
							Dados->CARENCAMB := Alltrim(Str(aNivCar[2])) + " "+cDesUnCar
						Else
							Dados->CARENCAMB := ""
						Endif
					ELse
						Dados->CARENCAMB := ""
					Endif

					If BDL->( msSeek(xFilial("BDL")+BA1->BA1_CODINT+Alltrim(GetNewPar("MV_PLCLHOS","XXX"))) )

						aNivCar := PlsClasCar({BDL->BDL_UNCAR,BDL->BDL_CARENC,"1",BDL->BDL_CODIGO,BDL->BDL_CODINT,BA1->BA1_DATCAR,.F.},;
							aDadUsr,'','',BA1->BA1_CODINT,BA3->BA3_CODPLA,BA3->BA3_VERSAO)

						If aNivCar[1] == "1" //1=Horas;2=Dias;3=Meses;4=Anos
							cDesUnCar := "Horas"
						ElseIf aNivCar[1] == "2"
							cDesUnCar := "Dias"
						ElseIf aNivCar[1] == "3"
							cDesUnCar := "Meses"
						ElseIf aNivCar[1] == "4"
							cDesUnCar := "Anos"
						Else
							cDesUnCar :=""
						Endif

						If Len(aNivCar) >= 7  .and. aNivCar[7]
							Dados->CARENCHOS := Alltrim(Str(aNivCar[2])) + " "+cDesUnCar
						Else
							Dados->CARENCHOS := ""
						Endif

					ELse
						Dados->CARENCHOS := ""
					Endif
					If BDL->( msSeek(xFilial("BDL")+BA1->BA1_CODINT+Alltrim(GetNewPar("MV_PLCLPAT","XXX"))) )

						aNivCar := PlsClasCar({BDL->BDL_UNCAR,BDL->BDL_CARENC,"1",BDL->BDL_CODIGO,BDL->BDL_CODINT,BA1->BA1_DATCAR,.F.},;
							aDadUsr,'','',BA1->BA1_CODINT,BA3->BA3_CODPLA,BA3->BA3_VERSAO)

						If aNivCar[1] == "1" //1=Horas;2=Dias;3=Meses;4=Anos
							cDesUnCar := "Horas"
						ElseIf aNivCar[1] == "2"
							cDesUnCar := "Dias"
						ElseIf aNivCar[1] == "3"
							cDesUnCar := "Meses"
						ElseIf aNivCar[1] == "4"
							cDesUnCar := "Anos"
						Else
							cDesUnCar :=""
						Endif

						If Len(aNivCar) >= 7  .and. aNivCar[7]
							Dados->CARENCPAT := Alltrim(Str(aNivCar[2])) + " "+cDesUnCar
						Else
							Dados->CARENCPAT := ""
						Endif
					ELse
						Dados->CARENCPAT := ""
					Endif

					If BDL->( msSeek(xFilial("BDL")+BA1->BA1_CODINT+Alltrim(GetNewPar("MV_PLCLODO","XXX"))) )

						aNivCar := PlsClasCar({BDL->BDL_UNCAR,BDL->BDL_CARENC,"1",BDL->BDL_CODIGO,BDL->BDL_CODINT,BA1->BA1_DATCAR,.F.},;
							aDadUsr,'','',BA1->BA1_CODINT,BA3->BA3_CODPLA,BA3->BA3_VERSAO)

						If aNivCar[1] == "1" //1=Horas;2=Dias;3=Meses;4=Anos
							cDesUnCar := "Horas"
						ElseIf aNivCar[1] == "2"
							cDesUnCar := "Dias"
						ElseIf aNivCar[1] == "3"
							cDesUnCar := "Meses"
						ElseIf aNivCar[1] == "4"
							cDesUnCar := "Anos"
						Else
							cDesUnCar :=""
						Endif

						If Len(aNivCar) >= 7  .and. aNivCar[7]
							Dados->CARENCODO := Alltrim(Str(aNivCar[2])) + " "+cDesUnCar
						Else
							Dados->CARENCODO := ""
						Endif

					ELse
						Dados->CARENCODO := ""
					Endif

					Dados->INFORMACOE := STR0055 //"Informações"
					Dados->CNESUSU	 :=  AllTrim(BTS->BTS_NRCRNA)
					Dados->SEGASSPL  :=  padr(substr(POSICIONE("BI6",1,XFILIAL("BI6")+ BI3->BI3_CODSEG,"BI6_DESCRI"),1,56),56)


					BMV->(DbSetOrder(1))//BMV_FILIAL+BMV_CODIGO
					If BMV->( MsSeek(xFilial("BMV")+"STR0019") )
						Dados->CONTATOANS := AllTrim(BMV->BMV_MSGPOR)
					Else
						Dados->CONTATOANS := ""
					Endif

					If BMV->( MsSeek(xFilial("BMV")+"STR0020") )
						Dados->CONTATOOPE := AllTrim(BMV->BMV_MSGPOR)
					Else
						Dados->CONTATOOPE := ""
					Endif

					Dados->CPT        := IIF(empty(dDatCpt),PadR('',12),substr(dtos(dDatCpt),7,2)+"/"+substr(dtos(dDatCpt),5,2)+"/"+substr(dtos(dDatCpt),1,4))

					BG9->(DbSetOrder(1))//BG9_FILIAL+BG9_CODINT+BG9_CODIGO+BG9_TIPO
					BG9->( msSeek( xFilial("BG9")+BA1->(BA1_CODINT+BA1_CODEMP) ) )


					If  BA3->BA3_TIPOUS == "1"
						Do Case
							Case BI3->BI3_NATJCO = "2"
								Dados->CONTRATACA := 'INDIVIDUAL OU FAMILIAR'
							Case BI3->BI3_NATJCO = "3"
								Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'
							Case BI3->BI3_NATJCO = "4"
								Dados->CONTRATACA := 'COLETIVO POR ADESAO'
							Case BI3->BI3_NATJCO = "5"
								Dados->CONTRATACA := 'BENEFICIENTE'
							Otherwise
								Dados->CONTRATACA := "SEM CONTRATACAO"
						EndCase
					Else
						If  AllTrim(BQC->BQC_ENTFIL) == "1"
							Dados->CONTRATACA := 'BENEFICIENTE'
						Else
							BII->(DbSetOrder(1))
							If lTpCtrBI3 .AND. BII->( msSeek(xFilial("BII")+BI3->BI3_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
								Do Case
									Case AllTrim(BII->BII_TIPPLA) == "1"
										Dados->CONTRATACA := 'INDIVIDUAL OU FAMILIAR'

									Case AllTrim(BII->BII_TIPPLA) == "2"
										Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'

									Case AllTrim(BII->BII_TIPPLA) == "3"
										Dados->CONTRATACA := 'COLETIVO POR ADESAO'
								EndCase
							Else
								If BII->( msSeek(xFilial("BII")+BT5->BT5_TIPCON) ) .AND. !EMPTY(BII->BII_TIPPLA)
									Do Case
										Case AllTrim(BII->BII_TIPPLA) == "1"
											Dados->CONTRATACA := 'INDIVIDUAL OU FAMILIAR'

										Case AllTrim(BII->BII_TIPPLA) == "2"
											Dados->CONTRATACA := 'COLETIVO EMPRESARIAL'

										Case AllTrim(BII->BII_TIPPLA) == "3"
											Dados->CONTRATACA := 'COLETIVO POR ADESAO'
									EndCase
								Endif
							EndIf
						Endif

						BTQ->(dbSetOrder(1))
						BTQ->(MsSeek(xFilial("BTQ") + "49" + AllTrim(BI3->BI3_CODACO)))

						Dados->TPACOMODA := BTQ->BTQ_DESTER

						If lBDENom .And. lTpBDENom
							If M->BDE_NOMCAR == "1"
								Dados->NOMEUSUARI := PadR(BTS->BTS_NOMCAR,25)
							Else
								Dados->NOMEUSUARI := PadR(BTS->BTS_NOMUSR,25)
							EndIf
						Else
							Dados->NOMEUSUARI := BTS->BTS_NOMCAR
						EndIF

						Dados->ABRANG := Posicione("BF7",1,xFilial("BF7")+BI3->BI3_ABRANG,"BF7_DESORI")

						Dados->DTVIGPL 	:= cDatXInsc
						Dados->NOMPRO   := BI3->BI3_NREDUZ
						Dados->SUSEP 	:= Iif(BI3->BI3_APOSRG == "1",BI3->BI3_SUSEP,BI3->BI3_SCPA)
						Dados->( MsUnlock() )

					Endif
					BED->( DbSkip() )
				Enddo

				dbSelectArea( "Dados" )
				DADOS->( dbGoTop() )

				If Alltrim(Dados->CONTRATACA) == "INDIVIDUAL OU FAMILIAR"
					DADOS->RZSOCIAL := ""
				EndIf

			EndIF
		EndIF
	EndIF


	aadd(aDados, {	alltrim(DADOS->NOMEUSUARI),;
		iif(FindFunction("PLSMATBEN") ,alltrim(PLSMATBEN(DADOS->MATRICULA)) ,alltrim(DADOS->MATRICULA)) ,;
		iif(empty(DADOS->DTNACTO)	,'',	alltrim(DADOS->DTNACTO)),;
		iif(empty(DADOS->CNESUSU)	,'',	alltrim(DADOS->CNESUSU)),;
		iif(empty(DADOS->SUSEP)		,'',	alltrim(DADOS->SUSEP)),;
		iif(empty(DADOS->SEGASSPL)	,'',	alltrim(DADOS->SEGASSPL)),;
		iif(empty(DADOS->NUMREGOPE)	,'',	alltrim(DADOS->NUMREGOPE)),;
		iif(empty(DADOS->CONTATOOPE),'',	alltrim(fwcutoff(DADOS->CONTATOOPE))),;
		iif(empty(DADOS->CONTATOANS),'',	alltrim(fwcutoff(DADOS->CONTATOANS))),;
		iif(empty(DADOS->CPT)		,'',	alltrim(DADOS->CPT)),;
		iif(empty(DADOS->TPACOMODA)	,'',	alltrim(DADOS->TPACOMODA)),;
		iif(empty(DADOS->CONTRATACA),'',	alltrim(DADOS->CONTRATACA)),;
		iif(empty(DADOS->ABRANG)	,'',	alltrim(DADOS->ABRANG)),;
		iif(empty(DADOS->NOMPRO)	,'',	alltrim(DADOS->NOMPRO)),;
		iif(empty(DADOS->NFANTAZOPE),'',	alltrim(DADOS->NFANTAZOPE)),;
		iif(empty(DADOS->NFAADMBENE),'',	alltrim(DADOS->NFAADMBENE)),;
		iif(empty(DADOS->RZSOCIAL)	,'',	alltrim(DADOS->RZSOCIAL)),;
		iif(empty(DADOS->DTVIGPL)	,'',	alltrim(DADOS->DTVIGPL)),;
		iif(empty(DADOS->NUMCON)	,'',	alltrim(DADOS->NUMCON)),;
		iif(empty(DADOS->DATCON)	,'',	alltrim(DADOS->DATCON)),;
		iif(empty(DADOS->DTMAXCON)	,'',	alltrim(DADOS->DTMAXCON)),;
		iif(empty(DADOS->INFOPLAN)	,'',	alltrim(DADOS->INFOPLAN)),;
		iif(empty(DADOS->INFORMACOE),'',	alltrim(DADOS->INFORMACOE)),;
		iif(empty(DADOS->CARENCAMB)	,'',	alltrim(DADOS->CARENCAMB )),;
		iif(empty(DADOS->CARENCHOS)	,'',	alltrim(DADOS->CARENCHOS )),;
		iif(empty(DADOS->CARENCPAT)	,'',	alltrim(DADOS->CARENCPAT )),;
		iif(empty(DADOS->CARENCODO)	,'',	alltrim(DADOS->CARENCODO )) } )

	oTempTable:Delete()
Return( aDados )
