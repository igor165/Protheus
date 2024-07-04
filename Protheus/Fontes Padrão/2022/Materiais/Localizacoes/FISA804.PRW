#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "LOCARG.CH"

Static oTmpTb1
Static oTmpTb2
Static oTmpTb3
Static oTmpTb4
Static oTmpTb5

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion    ³ FISA804    ³Autor ³ Emanuel V.V.        ³ Fecha ³08/01/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³ Archivo magnetico rutina principal (Argentina)             ³±±
±±³           ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ FISA804                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ACTUALIZACIONES SUFRIDAS DESDE LA CONSTRUCCION INICIAL         ³±±               
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Fecha  ³ Llamado³  Motivo de alteracion                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³08/01/16³ TTALPE ³ Generacion Archivos Ganancias Personas  ³±±
±±³            ³        ³        ³ Juridicas                               ³±±
±±³Alf. Medrano³10/03/17³ MMI-302³ asigna filtro de Fechas a query en func ³±±
±±³            ³        ³        ³ ActSf3. en la func ConcVal se asigan po-³±±
±±³            ³        ³        ³ -sicion dinamica al arary aImpuesto     ³±±
±±³Alf. Medrano³16/03/17³        ³ Creación de tablas temp FWTemporaryTable³±±
±±³            ³        ³        ³ en func ArchTmp. Se crean e inicializan ³±±
±±³            ³        ³        ³ variables static oTmpTb. Se elimina obj ³±±
±±³            ³        ³        ³ de tablas temp en func F804Cltmp.       ³±±
±±³            ³        ³        ³ Se quita la instrucción RETORDEM se cam-³±±
±±³            ³        ³        ³ bia por número correspondiente a índice ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FISA804(cArquivo,cDtIni,cDtFim,aCodTab)
Local nProcFil	:= 0
Local cBkpFil		:= cFilAnt
Local cSuc			:= Substr(aCodTab[1][3],1,1)
Local aTabs   	:= {}
Local aRel			:= {}
Local nPos			:= 0
Local nCanReg		:= 0

aTabs	:= ArchTmp(cArquivo) // Cursores temporales y nombres fisicos de los archivos.

If 	cSuc== "1" //Significa que sera consolidado y que hubo seleccion de Sucursales
	//Cambiar logico para que NO continue procesando filiales
	For nProcFil:=1 to len(aFilsCalc)
		If aFilsCalc[nProcFil,1] == .T.
			cFilAnt := aFilsCalc[nProcFil,2] // cFilAnt es la variable global que indica en que sucursal estamos trabajando
           aRel := F804Genera(cArquivo,cDtIni,cDtFim,aCodTab)
           aFilsCalc[nProcFil,1]:=.F.

           nPos:= Ascan(aRel,STR0025)
           If nPos <> 0
           	nCanReg += Val(Substr(aRel[nPos],Len(STR0025)+1))
           	aRel[nPos] := STR0025 + Alltrim(Str(nCanReg))	
           Endif 
		Endif
	Next nProcFil 
Else 
	aRel := F804Genera(cArquivo,cDtIni,cDtFim,aCodTab)
Endif 

cFilAnt := cBkpFil // Restaura Sucursal que se estaba utilizando
F804TRep(cArquivo,aRel)

Return aTabs

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao ³F804Genera   ºAutor  ³ Emanuel Villicaña  º Data ³  08/12/16   º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  ³Filtra la informacion y actualiza cursores temporales de       º±±
±±º       ³trabajo.                                                       º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno³                                                               º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso    ³FISA804                                                        º±±
±±ÈÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function F804Genera(cArquivo,cDtIni,cDtFim,aCodTab) //,lConfirm,aArTmp,lEsCons
Local aLogReg		:= {}
Local lErrores	:= .F.
Local cParam1		:= ""
Local cParam2		:= ""
Local cParam3		:= ""
Local cParam4		:= ""
Local cParam5		:= ""
Local nImp			:= 0
Default aCodTab 	:={}

If  Len(aCodTab)>0

	Aadd(aLogreg,Replicate("=",80))
	Aadd(aLogreg,STR0001) // "Parametros"
	Aadd(aLogreg,Replicate("=",80))  

	Aadd(aLogreg,STR0002 + Substr(cDtIni,7,4) + "/" + Substr(cDtIni,5,2) + "/" + Substr(cDtIni,1,4) ) //"Fecha Inicial:"
	Aadd(aLogreg,STR0003 + Substr(cDtFim,7,4) + "/" + Substr(cDtFim,5,2) + "/" + Substr(cDtFim,1,4) ) //"Fecha Final:"      
	
	////////////// "Inconsistencias"
	Aadd(aLogreg,Replicate("=",80))	
	Aadd(aLogreg,STR0005) 
	Aadd(aLogreg,Replicate("=",80))

	If Empty(cDtIni)
		Aadd(aLogreg,Alltrim(STR0002) + " " + Alltrim(STR0032) )
		lErrores := .T. 
	Endif 

	If Empty(cDtFim)
		Aadd(aLogreg,Alltrim(STR0003) + " " + Alltrim(STR0032) )
		lErrores := .T.  
	Endif 

	If cArquivo = "RG20628" // Tablas de equivalencia
		If Substr(aCodTab[1][2],1,2) $ "05|06"
			DbSelectArea("CCP")
			CCP->(DbSetOrder(1)) //CCP_FILIAL+CCP_COD+CCP_VORIGE
			CCP->(DbGoTop())
			If DbSeek(xFilial("CCP")+AvKey(aCodTab[1][4],"CCP_COD"))
				Aadd(aLogreg,STR0004+SPACE(1)+Alltrim(aCodTab[1][4])+SPACE(1)+Alltrim(CCP->CCP_DESCR)+Space(1)+STR0007)//"Tabela de Equivalencia "#" informado nao cadastrado"
			Else
				Aadd(aLogreg,STR0004+SPACE(1)+Alltrim(aCodTab[1][4])+SPACE(1)+STR0007+Space(1)+STR0008)//"Tabela de Equivalencia "#" nao cadastrado"
				lErrores := .T. 
			Endif
			If DbSeek(xFilial("CCP")+AvKey(aCodTab[1][5],"CCP_COD")) 
				Aadd(aLogreg,STR0004+SPACE(1)+Alltrim(aCodTab[1][5])+SPACE(1)+Alltrim(CCP->CCP_DESCR)+Space(1)+STR0007)//"Tabela de Equivalencia "#" informado nao cadastrado"
			Else
				Aadd(aLogreg,STR0004+SPACE(1)+Alltrim(aCodTab[1][5])+SPACE(1)+STR0007+Space(1)+STR0008)//"Tabela de Equivalencia "#" nao cadastrado"
				lErrores := .T. 
			Endif
		Endif
	Endif
	
	Aadd(aLogreg,Replicate("=",80))	
	If lErrores == .T. // Se detecto Errores en la carga de parametros que eviten funcionamiento correcto.
		Return aLogreg
	Endif 
	////////////// 
	If cArquivo = "RG20628"
		cParam1	:= Substr(aCodTab[1][1],1,1) // Tasa
		cParam2	:= Substr(aCodTab[1][2],1,2) // Tip. Archivo
		cParam3	:= Substr(aCodTab[1][3],1,1) // Acumulativo
		cParam4	:= Substr(aCodTab[1][4],1,4) // Tabla equivalencias Retenciones
		cParam5	:= Substr(aCodTab[1][5],1,5) // Tabla equivalencias Percepciones
	
		Aadd(aLogreg,STR0048 + " " + cArquivo) 
		Aadd(aLogreg,Replicate("=",80))
				
		If cParam2 <> "06"
			If cParam2 $ "01|06" // 01 - Activo Exterior
				Aadd(aLogreg,STR0076 + " " + STR0077 + " " + cArquivo) //ACTIVO EXTERIOR
				ActCxC(cArquivo,cDtIni,cDtFim,cParam1,cParam2,cParam3,@aLogreg,cParam2,@nImp)
			Endif  
			If cParam2 $ "02|06" // 02 - Activo Locales.
				Aadd(aLogreg,STR0076 + " " + STR0078 + " " + cArquivo) //ACTIVO LOCAL
				ActCxC(cArquivo,cDtIni,cDtFim,cParam1,cParam2,cParam3,@aLogreg,cParam2,@nImp)
			Endif  
			// PASIVO		
			If cParam2 $ "03" // Exterior
				Aadd(aLogreg,STR0075 + " " + STR0077 + " " + cArquivo) //PASIVO EXTERIOR
				ActCxP(cArquivo,cDtIni,cDtFim,cParam1,cParam2,cParam3,@aLogreg,cParam2,@nImp)
			Endif  
			If cParam2 $ "04" // Locales
				Aadd(aLogreg,STR0075 + " " + STR0078 + " " + cArquivo) //PASIVO LOCAL
				ActCxP(cArquivo,cDtIni,cDtFim,cParam1,cParam2,cParam3,@aLogreg,cParam2,@nImp)
			Endif
		Else
			Aadd(aLogreg,STR0076 + " " + STR0077 + " " + cArquivo) //ACTIVO EXTERIOR
			Aadd(aLogreg,STR0076 + " " + STR0078 + " " + cArquivo) //ACTIVO LOCAL
		
			ActCxC(cArquivo,cDtIni,cDtFim,cParam1,cParam2,cParam3,@aLogreg,cParam2,@nImp)

			Aadd(aLogreg,STR0075 + " " + STR0077 + " " + cArquivo) //PASIVO EXTERIOR
			Aadd(aLogreg,STR0075 + " " + STR0078 + " " + cArquivo) //PASIVO LOCAL

			ActCxP(cArquivo,cDtIni,cDtFim,cParam1,cParam2,cParam3,@aLogreg,cParam2,@nImp)
		Endif 
		
		If cParam2 $ "05|06" // 05 - Retenciones Percepciones
			ActSFE(cArquivo,cDtIni,cDtFim,cParam1,cParam2,cParam3,cParam4,@aLogreg,@nImp) // Retenciones 
			ActSF3(cArquivo,cDtIni,cDtFim,cParam1,cParam2,cParam3,cParam5,@aLogreg,@nImp) // Percepciones
		Endif  
		Aadd(aLogreg,Replicate("=",80))
	Endif 
Endif 

Aadd(aLogreg,Replicate("=",80))	
Aadd(aLogreg,STR0025 + SPACE(1) + Alltrim(Str(nImp) ))	//"Quantidade de Registros gerado: "
Aadd(aLogreg,Replicate("=",80))	

Return aLogreg

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion     ³ ActCxC     ³Autor ³ Emanuel V.V.        ³ Fecha ³11/01/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³ Archivo magnetico (Argentina)                              ³±±
±±³            ³ 01 - A.C. Deudores por Vta o Ser. del Exterior o Todos     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ FISA804                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Fecha  ³ Llamado³  Motivo de alteracion                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³        ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ActCxC(cArquivo,cDtIni,cDtFim,cParam1,cParam2,cParam3,aLogreg,cTipArch,nImp)

Local dDtIni	:= STOD(cDtIni)
Local dDtFin	:= STOD(cDtFim)
Local dDataTit:= MIN(dDataBase,dDtFin)
//Local cTipos	:= "DP|NF|FT|NDP|NCP|NCC|NDC|PA|RA|CH"
Local cTipos := ExecBlock("FARGTIP",.F.,.F.)
Local cNeg		:= MV_CRNEG + "|RA"
Local nSaldo:=0
Local nSigno:=1

DbSelectArea("SA1") 
SA1->(DbSetOrder(1))//A1_FILIAL+A1_COD+A1_LOJA

DbSelectArea("SE1")
DbSetOrder(2)//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
DbSeek(xFilial("SE1"))

ProcRegua( LastRec() )

If SE1->(!Eof())
	While	SE1->(!Eof())  .AND. xFilial("SE1") == SE1->E1_FILIAL
	
		If (Val(SE1->E1_SITUACA) > 0) .or.  (SE1->E1_EMISSAO > dDataTit)
			SE1->(DbSkip())
			Loop
	   Endif
	
		If !(Alltrim(SE1->E1_TIPO) $ cTipos)
			SE1->(DbSkip())
			Loop
		EndIf
	
		nSaldo   := SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,1,,dDataBase,SE1->E1_LOJA,,Iif(cParam1 == "M",Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0))
	
		If nSaldo < 0
			SE1->(DbSkip())
			Loop
		Endif
	
		If Alltrim(SE1->E1_TIPO) $ cNeg
			nSigno := -1
		Else
			nSigno := 1
		Endif
	
		If SE1->E1_EMISSAO >= dDtIni 
			If SA1->(DbSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA))
				If cTipArch $ "01|06" .and. SA1->A1_PAIS <> "063" .and. Alltrim(SA1->A1_AFIP) $ "1|7" // Activo Exterior 
					If ACDVSE->(DbSeek(SA1->A1_CGC))
						Reclock("ACDVSE",.F.)
						ACDVSE->ACE_SAL	+= (nSaldo * nSigno)
						ACDVSE->ACE_SALDO	:= Transform(ACDVSE->ACE_SAL,"@E 999999999999.99")

						ACDVSE->(MsUnlock())
					Else
					 	RecLock("ACDVSE",.T.)
						ACDVSE->ACE_CUIT	:= SA1->A1_CGC
						ACDVSE->ACE_RAZON	:= SA1->A1_NOME
						ACDVSE->ACE_SAL	:= (nSaldo * nSigno)
						ACDVSE->ACE_SALDO	:= Transform(ACDVSE->ACE_SAL,"@E 999999999999.99") 
						ACDVSE->ACE_EXT	:= "0"
						nImp++ 
					 	ACDVSE->(MsUnlock())
					Endif
				ElseIf cTipArch $ "02|06" .and. SA1->A1_PAIS == "063" .and. Alltrim(SA1->A1_AFIP) $ "1|7" // Activo Locales
					If ACDVSL->(DbSeek(SA1->A1_CGC))
						Reclock("ACDVSL",.F.)
						ACDVSL->ACE_SAL	+= (nSaldo * nSigno)
						ACDVSL->ACE_SALDO	:= Transform(ACDVSL->ACE_SAL,"@E 999999999999.99") 

						ACDVSL->(MsUnlock())
					Else
					 	RecLock("ACDVSL",.T.)
						ACDVSL->ACE_CUIT	:= SA1->A1_CGC
						ACDVSL->ACE_RAZON	:= SA1->A1_NOME
						ACDVSL->ACE_SAL	:= (nSaldo * nSigno)
						ACDVSL->ACE_SALDO	:= Transform(ACDVSL->ACE_SAL,"@E 999999999999.99") 
						ACDVSL->ACE_EXT	:= "0"
						nImp++ 
					 	ACDVSL->(MsUnlock())
					Endif
				
				Endif		
			Endif
	   Endif
	   
		SE1->(dbSkip())
	Enddo
Endif
Return aLogreg

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion     ³ ActCxP     ³Autor ³ Emanuel V.V.        ³ Fecha ³12/01/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³ Archivo magnetico (Argentina)                              ³±±
±±³            ³ 03 Pasivo - Deudas Comerciales del Exterior.               ³±±
±±³            ³ 04 Pasivo - Deudas Comerciales del Locales.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ FISA804                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Fecha  ³ Llamado³  Motivo de alteracion                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³        ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ActCxP(cArquivo,cDtIni,cDtFim,cParam1,cParam2,cParam3,aLogreg,cTipArch,nImp)

Local dDtIni	:= STOD(cDtIni)
Local dDtFin	:= STOD(cDtFim)
//Local cTipos	:= "DP|NF|FT|NDP|NCP|NCC|NDC|PA|RA|CH"
Local cTipos := ExecBlock("FARGTIP",.F.,.F.)
Local cNeg		:= MV_CPNEG + "|PA "
Local nSaldo:=0
Local nSigno:=1

DbSelectArea("SA2")
SA2->(DbSetOrder(1))//A2_FILIAL+A2_COD+A2_LOJA

DbSelectArea("SE2")
DbSetOrder(6)//E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
DbSeek(xFilial("SE2"))

ProcRegua( LastRec() )

If SE2->(!Eof())
	While	SE2->(!Eof())  .AND. xFilial("SE2") == SE2->E2_FILIAL
	
		If (Val(SE2->E2_SITUACA) > 0) .or.  (SE2->E2_EMISSAO > dDtFin)
			SE2->(DbSkip())
			Loop
	   Endif
	
		If !(Alltrim(SE2->E2_TIPO) $ cTipos)
			SE2->(DbSkip())
			Loop
		EndIf
	
		nSaldo   := SaldoTit(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_NATUREZ,"P",SE2->E2_FORNECE,1,,dDataBase,SE2->E2_LOJA,,Iif(cParam1 == "M",Iif(!Empty(SE2->E2_TXMOEDA),SE2->E2_TXMOEDA,RecMoeda(SE2->E2_EMISSAO,SE2->E2_MOEDA)),0))
	
		If nSaldo <= 0
			SE2->(DbSkip())
			Loop
		Endif
	
		If Alltrim(SE2->E2_TIPO) $ cNeg
			nSigno := -1
		Else
			nSigno := 1
		Endif
	
		If SE2->E2_EMISSAO >= dDtIni 
			If SA2->(DbSeek(xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA))
				If cTipArch $ "03|06" .and. SA2->A2_PAIS <> "063" .and. Alltrim(SA2->A2_AFIP) $ "1|7" // Activo Exterior 
					If PDCEXT->(DbSeek(SA2->A2_CGC))
						Reclock("PDCEXT",.F.)
						PDCEXT->ACE_SAL	+= (nSaldo * nSigno)
						PDCEXT->ACE_SALDO	:= Transform(PDCEXT->ACE_SAL,"@E 999999999999.99")  

						PDCEXT->(MsUnlock())
					Else
					 	RecLock("PDCEXT",.T.)
						PDCEXT->ACE_CUIT	:= SA2->A2_CGC
						PDCEXT->ACE_RAZON	:= SA2->A2_NOME
						PDCEXT->ACE_SAL	:= (nSaldo * nSigno)
						PDCEXT->ACE_SALDO	:= Transform(PDCEXT->ACE_SAL,"@E 999999999999.99") 
						nImp++ 
					 	PDCEXT->(MsUnlock())
					Endif
				ElseIf cTipArch $ "04|06" .and. SA2->A2_PAIS == "063" .and. Alltrim(SA2->A2_AFIP) $ "1|7" // Activo Locales
					If PDCLOC->(DbSeek(SA2->A2_CGC))
						Reclock("PDCLOC",.F.)
						PDCLOC->ACE_SAL	+= (nSaldo * nSigno)
						PDCLOC->ACE_SALDO	:= Transform(PDCLOC->ACE_SAL,"@E 999999999999.99")  

						PDCLOC->(MsUnlock())
					Else
					 	RecLock("PDCLOC",.T.)
						PDCLOC->ACE_CUIT	:= SA2->A2_CGC
						PDCLOC->ACE_RAZON	:= SA2->A2_NOME
						PDCLOC->ACE_SAL	:= (nSaldo * nSigno)
						PDCLOC->ACE_SALDO	:= Transform(PDCLOC->ACE_SAL,"@E 999999999999.99") 
						nImp++ 
					 	PDCLOC->(MsUnlock())
					Endif
				
				Endif		
			Endif
	   Endif
		SE2->(dbSkip())
	Enddo
Endif 

Return aLogreg

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion     ³ ActSFE     ³Autor ³ Emanuel V.V.        ³ Fecha ³13/01/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³ Archivo magnetico (Argentina)                              ³±±
±±³            ³ 05 Retenciones y percepciones. (RETENCIONES)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ FISA804                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Fecha  ³ Llamado³  Motivo de alteracion                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³        ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ActSFE(cArquivo,cDtIni,cDtFim,cParam1,cParam2,cParam3,cParam4,aLogreg,nImp)
Local cQryRet	:= ""
Local cTRBRET	:=""
Local cCodTab1:= ""
Local cCerti	:= ""

DbSelectArea("SA1")
SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA

DbSelectArea("CCP")
CCP->(DbSetOrder(1)) //CCP_FILIAL+CCP_COD+CCP_VORIGE

cQryRet := " SELECT FE_CFO, FE_CLIENTE,FE_NROCERT,FE_EMISSAO, FE_RETENC,FE_DTRETOR "
cQryRet += " ,COALESCE(A1_CGC,'') A1_CGC, COALESCE(A1_NOME,'') A1_NOME, COALESCE(A1_AFIP,'') A1_AFIP "
cQryRet += " FROM "+RetsqlName("SFE")+" SFE "
cQryRet += " LEFT JOIN "+RetsqlName("SA1")+" SA1 ON "
cQryRet += " A1_FILIAL = '"+xFilial("SA1")+"' "
cQryRet += " AND FE_CLIENTE=A1_COD "
cQryRet += " AND FE_LOJCLI=A1_LOJA "
cQryRet += " AND SA1.D_E_L_E_T_=''
cQryRet += " WHERE SFE.D_E_L_E_T_='' "
cQryRet += " AND FE_FILIAL = '"+xFilial("SFE")+"' "
	
If cArquivo = "RG20628"
	cQryRet += " AND FE_NROCERT <> 'NORET' "
	cQryRet += " AND FE_TIPO = 'G' " // Ganancias
	cQryRet += " AND FE_CLIENTE<>'' "
	cQryRet += " AND FE_RETENC <> 0 "
	cQryRet += " AND FE_EMISSAO BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' "
	cQryRet += " ORDER BY FE_CLIENTE,FE_NROCERT,FE_EMISSAO,FE_DTRETOR"
Endif 

If Select("TRBRET")>0
	DbSelectArea("TRBRET")
	TRBRET->(DbCloseArea())
Endif

cTRBRET := ChangeQuery(cQryRet)
dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBRET ) ,"TRBRET", .T., .F.)
			
DbSelectArea("TRBRET")
TRBRET->(dbGoTop())
If TRBRET->(!Eof())
	Aadd(aLogreg,STR0016 + " " + cArquivo)//RETENCAO
	Do While TRBRET->(!Eof())

		If cArquivo = "RG20628" .and. Alltrim(TRBRET->A1_AFIP) $ "1|7"
			DbSelectArea("CCP")
			If CCP->(DbSeek(xFilial("CCP") + AvKey(cParam4,"CCP_COD") + AvKey(TRBRET->FE_CFO,"CCP_VORIGE")))
				cCodTab1:= Alltrim(CCP->CCP_VDESTI)
			Endif 
			If Empty(cCodTab1)
				Aadd(aLogreg,Replicate("=",40))
				Aadd(aLogreg,STR0017 + SPACE(1) + ALLTRIM(TRBRET->FE_NROCERT)) // "Numero Certificado:"
				Aadd(aLogreg,STR0014 + SPACE(1) + TRBRET->FE_CFO + SPACE(1) + STR0015 + SPACE(1) + cParam4 + " " + CCP->CCP_DESCR) // "Codigo CFO: "#" no tiene codigo equivalente en la Tabla de Equivalencia"
			Endif

			cCerti := SPACE(30-LEN(ALLTRIM(TRBRET->FE_NROCERT))) + ALLTRIM(TRBRET->FE_NROCERT)
			If RETPER->(DbSeek(Substr(TRBRET->A1_CGC,1,11) + cCerti + "1" )) // RP_CUIT+RP_CERTIF+RP_TIPOP
				Reclock("RETPER",.F.)
				RETPER->RP_SAL	+= TRBRET->FE_RETENC
				RETPER->RP_IMPOR	:= Transform(RETPER->RP_SAL,"@E 999999999999.99")  

				RETPER->(MsUnlock())
			Else
			 	RecLock("RETPER",.T.)
			 	RETPER->RP_TIPOP	:= "1"
			 	RETPER->RP_CUIT	:= Substr(TRBRET->A1_CGC,1,11)
			 	RETPER->RP_FECRET	:= Substr(TRBRET->FE_EMISSAO,7,2) + "/" + Substr(TRBRET->FE_EMISSAO,5,2) + "/" + Substr(TRBRET->FE_EMISSAO,1,4)
			 	RETPER->RP_CODREG	:= cCodTab1
			 	RETPER->RP_SAL	:= TRBRET->FE_RETENC
			 	RETPER->RP_IMPOR	:= Transform(RETPER->RP_SAL,"@E 999999999999.99")
			 	RETPER->RP_CERTIF	:= cCerti
				nImp++	 
			 	RETPER->(MsUnlock())
			Endif
		Endif
		 
		TRBRET->(DbSkip())		
	Enddo 
Endif 
 
TRBRET->(DbCloseArea())
 
Return aLogreg

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao ³ArchTmp      ºAutor  ³ Emanuel Villicaña  º Data ³  08/12/16   º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  ³Monta los archivos temporales de trabajo.                      º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno³aTabs - Array contendiendo los alias abiertos en la funcion    º±±
±±ÌÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso    ³FISA804                                                        º±±
±±ÈÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ArchTmp(cArquivo)

Local aTabs		:= {}
Local aStruVc1	:= {} 
Local cArqVc1		:= ""

If cArquivo = "RG20628"
	// CxC
	// Activo - Creditos - Deudores por Venta o Servicios del Exterior
	cArqVc1	:= ""
	aStruVc1	:= {}
			
	AADD(aStruVc1,{"ACE_CUIT"   ,"C",011,0}) // CUIT
	AADD(aStruVc1,{"ACE_RAZON"  ,"C",050,0}) // Nombre y Apellido o Razon Social 
	AADD(aStruVc1,{"ACE_SALDO"  ,"C",015,0}) // Saldo al Cierre
	AADD(aStruVc1,{"ACE_EXT"    ,"C",001,0}) // Default 0
	AADD(aStruVc1,{"ACE_SAL"    ,"N",013,2}) // Saldo al Cierre	
	
	//Creacion de la tabla
	oTmpTb1 := FWTemporaryTable():New("ACDVSE")
	oTmpTb1:SetFields( aStruVc1 )
	oTmpTb1:AddIndex("T1ORD1", {"ACE_CUIT"}) 
	oTmpTb1:Create() 
	
	DbSelectArea("ACDVSE")
	DbSetOrder(1)
	aAdd(aTabs,{"ACDVSE",cArqVc1,"oTmpTb1"})
	
	// Activo - Creditos - Deudores por Venta o Servicios del Locales
	cArqVc1	:= ""
	aStruVc1	:= {}
			
	AADD(aStruVc1,{"ACE_CUIT"   ,"C",011,0}) // CUIT
	AADD(aStruVc1,{"ACE_RAZON"  ,"C",050,0}) // Nombre y Apellido o Razon Social 
	AADD(aStruVc1,{"ACE_SALDO"  ,"C",015,0}) // Saldo al Cierre
	AADD(aStruVc1,{"ACE_EXT"    ,"C",001,0}) // Default 0
	AADD(aStruVc1,{"ACE_SAL"    ,"N",013,2}) // Saldo al Cierre			
	
	//Creacion de la tabla
	oTmpTb2 := FWTemporaryTable():New("ACDVSL")
	oTmpTb2:SetFields( aStruVc1 )
	oTmpTb2:AddIndex("T1ORD1", {"ACE_CUIT"})
	oTmpTb2:Create() 
			
	DbSelectArea("ACDVSL")
	DbSetOrder(1)
	aAdd(aTabs,{"ACDVSL",cArqVc1,"oTmpTb2"})
	
	// CxP
	// Pasivo Exterior
	cArqVc1	:= ""
	aStruVc1	:= {}
			
	AADD(aStruVc1,{"ACE_CUIT"   ,"C",011,0}) // CUIT
	AADD(aStruVc1,{"ACE_RAZON"  ,"C",050,0}) // Nombre y Apellido o Razon Social 
	AADD(aStruVc1,{"ACE_SALDO"  ,"C",015,0}) // Saldo al Cierre
	AADD(aStruVc1,{"ACE_SAL"    ,"N",013,2}) // Saldo al Cierre			

	//Creacion de la tabla
	oTmpTb3 := FWTemporaryTable():New("PDCEXT")
	oTmpTb3:SetFields( aStruVc1 )
	oTmpTb3:AddIndex("T1ORD1", {"ACE_CUIT"})
	oTmpTb3:Create() 
		
	DbSelectArea("PDCEXT")
	DbSetOrder(1)
	aAdd(aTabs,{"PDCEXT",cArqVc1,"oTmpTb3"})
	
	// Pasivo Locales
	cArqVc1	:= ""
	aStruVc1	:= {}
			
	AADD(aStruVc1,{"ACE_CUIT"   ,"C",011,0}) // CUIT
	AADD(aStruVc1,{"ACE_RAZON"  ,"C",050,0}) // Nombre y Apellido o Razon Social 
	AADD(aStruVc1,{"ACE_SALDO"  ,"C",015,0}) // Saldo al Cierre
	AADD(aStruVc1,{"ACE_SAL"    ,"N",013,2}) // Saldo al Cierre			
	
	//Creacion de la tabla
	oTmpTb4 := FWTemporaryTable():New("PDCLOC")
	oTmpTb4:SetFields( aStruVc1 )
	oTmpTb4:AddIndex("T1ORD1", {"ACE_CUIT"})
	oTmpTb4:Create()
			
	DbSelectArea("PDCLOC")
	DbSetOrder(1)
	aAdd(aTabs,{"PDCLOC",cArqVc1,"oTmpTb4"})

	// RETENCIONES PERCEPCIONES
	cArqVc1	:= ""
	aStruVc1	:= {}
			
	AADD(aStruVc1,{"RP_TIPOP"   ,"C",001,0}) // Tipo de Operacion
	AADD(aStruVc1,{"RP_CUIT"    ,"C",011,0}) // Cuit del agente de retencion
	AADD(aStruVc1,{"RP_FECRET"  ,"C",010,0}) // Fecha de la retencion
	AADD(aStruVc1,{"RP_CODREG"  ,"C",003,0}) // Codigo de Regimen
	AADD(aStruVc1,{"RP_IMPOR"   ,"C",015,0}) // Importe
	AADD(aStruVc1,{"RP_CERTIF"  ,"C",030,0}) // Numero de Certificado
	AADD(aStruVc1,{"RP_SAL"    ,"N",013,2}) // Importe
	
	//Creacion de la tabla
	oTmpTb5 := FWTemporaryTable():New("RETPER")
	oTmpTb5:SetFields( aStruVc1 )
	oTmpTb5:AddIndex("T1ORD1", {"RP_CUIT", "RP_CERTIF","RP_TIPOP"})		
	oTmpTb5:Create()	
			
	DbSelectArea("RETPER")
	DbSetOrder(1)
	aAdd(aTabs,{"RETPER",cArqVc1,"oTmpTb5"})
	
Endif 

Return aTabs

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³F804TRep  º Autor ³ Emanuel Villicana  º Data ³  08/01/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Informe de Archivo Magnetico                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function F804TRep(cTitulo,aLogArq)
	Local oReport
	Local aArea			:= GetArea()
	Private cPerg  		:= ""
	Private aOrd		:= {}

	If ValType(aLogArq) <> "A"
		aLogReg := {}
	Endif  
 
	oReport := F804Log(cTitulo,aLogArq)//TREPORT
	oReport:PrintDialog()
	RestArea( aArea )
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F804Log   ºAutor  ³Marcos Kato         º Data ³  16/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Estrtura do Relatorio em TREPORT                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function F804Log(cTitulo,aLogArq)
	Local oReport
	Local oSection
	Local cDesc	  	:= STR0026 + Space(1) + cTitulo // "Impressao do Log do Arquivo Magnetico"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao dos componentes de impressao                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE REPORT oReport NAME STR0028 TITLE cTitulo PARAMETER cPerg ACTION {|oReport| F804Imp(oReport,aLogArq)} DESCRIPTION cDesc TOTAL IN COLUMN
	oReport:SetPortrait(.T.)//Impressao Retrato
	
   	//oReport:DisableOrientation()//Desabilita a mudanca de impressao
   	//-------------------------------------------------------------------------------------------------------
	// oSection = usado para montar o cabeçalho do relatorio
	//-------------------------------------------------------------------------------------------------------
	DEFINE SECTION oSection OF oReport TITLE OemToAnsi(cTitulo) ORDERS aOrd TABLE "" TOTAL IN COLUMN
		//oSection1:SetLineStyle()	// Impressao da descricao e conteudo do campo na mesma linha      
	DEFINE CELL NAME "LISTA" 		OF oSection TITLE STR0027  SIZE 200//"RESULTADO DO LOG ARQUIVO MAGNETICO"
		
Return oReport

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F804Imp   ºAutor  ³Marcos Kato         º Data ³  16/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao do Detalhe do Relatorio em TREPORT                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function F804Imp(oReport,aLogArq)
Local oSection := oReport:Section(1)
Local nOrdem   := oSection:GetOrder()
Local nCont    := 0

oSection:Init()
For nCont:=1 To Len(aLogArq)
	oReport:IncMeter()
	If oReport:Cancel()
		Exit
	EndIf
	oSection:Cell("LISTA"	):SetBlock({||aLogArq[nCont]})
	oSection:PrintLine()
End
oSection:Finish()

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³F804Cltmp ³ Autor ³ Ivan Haponczuk      ³ Data ³ 09.11.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ Executa operacoes apos a geracao dos arquivos magneticos.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cProv    - Provincia do arquivo gerado.                    ³±±
±±³            ³ aTabs    - [1] Nome do alias criado.                       ³±±
±±³            ³            [2] Nome do arquivo fisico criado.              ³±±
±±³            ³            [3] Indice de ordenacao do arquivo.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal Argentina - MATA950 - Arquivos Magneticos           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function F804Cltmp(aTabs)   
Local nI := 0

For nI:=1 To Len(aTabs)
	If Select(aTabs[nI,1]) > 0
		dbSelectArea(aTabs[nI,1])
		&(aTabs[nI,1])->(dbCloseArea())
		//Elimina Archivos Temporales oTmpTable
		If &(aTabs[nI,3]) <> NIL
			&(aTabs[nI,3]):Delete()
			&(aTabs[nI,3]) := NIL
		EndIf
	EndIf
Next nI

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion     ³ ActSf3     ³Autor ³ Emanuel V.V.        ³ Fecha ³13/01/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion ³ Archivo magnetico (Argentina)                              ³±±
±±³            ³ 05 Retenciones y percepciones. (PERCEPCIONES)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ FISA804                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Fecha  ³ Llamado³  Motivo de alteracion                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³        ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ActSf3(cArquivo,cDtIni,cDtFim,cParam1,cParam2,cParam3,cParam5,aLogreg,nImp)

Local aPerGan	:= FilImp({"4"},{"P"},{"N"},{}) // Retorna todos los impuestos de Ganancias
Local cCodTab1:= ""
Local cCerti	:= ""
Local cQryPer	:= ""

DbSelectArea("CCP")
CCP->(DbSetOrder(1)) //CCP_FILIAL+CCP_COD+CCP_VORIGE
CCP->(DbGoTop())

cQryPer := " SELECT SF3.* , "
cQryPer += " COALESCE(A2_CGC,'') A2_CGC, COALESCE(A2_NOME,'') A2_NOME, COALESCE(A2_AFIP,'') A2_AFIP "
cQryPer += " FROM "+RetsqlName("SF3")+" SF3 "

cQryPer += " INNER JOIN "+RetsqlName("SA2")+" SA2 ON "
cQryPer += " A2_FILIAL = '" + xFilial("SA2") + "' "
cQryPer += " AND F3_CLIEFOR = A2_COD "
cQryPer += " AND F3_LOJA = A2_LOJA "
cQryPer += " AND SA2.D_E_L_E_T_='' "

cQryPer += " WHERE SF3.D_E_L_E_T_='' "
cQryPer += " AND F3_FILIAL = '" + xFilial("SF3") + "' "
cQryPer += " AND F3_TIPOMOV = 'C' "
cQryPer += " AND F3_ESPECIE IN ('NF','NDP','NCP') "
cQryPer += " AND F3_EMISSAO BETWEEN '" + cDtIni + "' AND '" + cDtFim + "' "

cQryPer += ConcVal(aPerGan) 

If Select("TRBPER")>0
	DbSelectArea("TRBPER")
	TRBPER->(DbCloseArea())
Endif
			
cTRBPER := ChangeQuery(cQryPer)
dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBPER ) ,"TRBPER", .T., .F.)
						
DbSelectArea("TRBPER")
TRBPER->(dbGoTop())
If TRBPER->(!Eof()) 
	Aadd(aLogreg,STR0010 + " " + cArquivo)//"PERCEPCAO"
	
	Do While TRBPER->(!Eof())
		If cArquivo = "RG20628" .and. Alltrim(TRBPER->A2_AFIP) $ "1|7"
			If CCP->(DbSeek(xFilial("CCP") + AvKey(cParam5,"CCP_COD") + AvKey(TRBPER->F3_CFO,"CCP_VORIGE")))
				cCodTab1:= Alltrim(CCP->CCP_VDESTI)
			Else 
				cCodTab1:= ""
			Endif 
			
			If Empty(cCodTab1)
				Aadd(aLogreg,Replicate("=",40))			
				Aadd(aLogreg,STR0017 + SPACE(1) + ALLTRIM(TRBPER->F3_NFISCAL)) // "Numero Certificado:"
				Aadd(aLogreg,STR0014 + SPACE(1) + TRBPER->F3_CFO + SPACE(1) + STR0015 + SPACE(1) + cParam5 + " " + CCP->CCP_DESCR) // "Codigo CFO: "#" no tiene codigo equivalente en la Tabla de Equivalencia"
			Endif
	
			cCerti := SPACE(30-LEN(ALLTRIM(TRBPER->F3_NFISCAL))) + ALLTRIM(TRBPER->F3_NFISCAL)
			If RETPER->(DbSeek(Substr(TRBPER->A2_CGC,1,11) + cCerti + "2" )) // RP_CUIT+RP_CERTIF+RP_TIPOP
				Reclock("RETPER",.F.)
				RETPER->RP_SAL	+= ValImp("TRBPER",aPerGan,"SF3V") 
				RETPER->RP_IMPOR	:= Transform(RETPER->RP_SAL,"@E 999999999999.99")  
	
				RETPER->(MsUnlock())
			Else
			 	RecLock("RETPER",.T.)
			 	RETPER->RP_TIPOP	:= "2"
			 	RETPER->RP_CUIT	:= Substr(TRBPER->A2_CGC,1,11)
			 	RETPER->RP_FECRET	:= Substr(TRBPER->F3_EMISSAO,7,2) + "/" + Substr(TRBPER->F3_EMISSAO,5,2) + "/" + Substr(TRBPER->F3_EMISSAO,1,4)
			 	RETPER->RP_CODREG	:= cCodTab1
			 	RETPER->RP_SAL	:= ValImp("TRBPER",aPerGan,"SF3V")
			 	RETPER->RP_IMPOR	:= Transform(RETPER->RP_SAL,"@E 999999999999.99")
			 	RETPER->RP_CERTIF	:= cCerti
				nImp++		 
			 	RETPER->(MsUnlock())
			Endif
		Endif
		TRBPER->(DbSkip())
	Enddo	
Endif

TRBPER->(DbCloseArea())
Return aLogreg

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ConcVal     º Autor ºEmanuel Villicana º Data º  14/01/15  º±±
±±ºÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna cadena concatenada con todos los campos que se     º±±
±±º          ³ del impuesto para ser utilizada en consulta.               º±±
±±ºÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FISA804                                                    º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ConcVal(aImpuesto)
Local cRetorno	:= ""
Local nlI			:= 0
 
If Len(aImpuesto) > 0   
	cRetorno += " AND ("
	For nlI:=1 To Len(aImpuesto)
		If !(aImpuesto[nlI][9] $ cRetorno)
			If nlI <> 1
				cRetorno += " OR "
			EndIf
			cRetorno += " " + aImpuesto[nlI][9] + " > 0 "
		Endif
	Next nlI
	cRetorno += ")"
EndIf

Return cRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ValImp      º Autor ºEmanuel Villicana º Data º  14/01/15  º±±
±±ºÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna la suma de la Base o Valor de un impuesto          º±±
±±ºDescricao ³ o percepcion                                               º±±
±±ºÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FISA804                                                    º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ValImp(cAliasTmp,aImpuesto,cTipCam)
Local nRetorno	:= 0
Local nlI := 0

If Len(aImpuesto) > 0
	For nlI:=1 To Len(aImpuesto)
		If cTipCam = "SF3B" .and. &((cAliasTmp) +"->" + aImpuesto[nlI][7]) > 0 // Base
			nRetorno += &((cAliasTmp) +"->" + aImpuesto[nlI][7])
		ElseIf cTipCam = "SF3V" .and. &((cAliasTmp) +"->" + aImpuesto[nlI][9]) > 0  // Valor 
			nRetorno += &((cAliasTmp) +"->" + aImpuesto[nlI][9])
		Endif 
	Next nlI
Endif
Return nRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FilImp      º Autor ºEmanuel Villicana º Data º  11/01/15  º±±
±±ºÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Extrae de SFB informacion filtrando                        º±±
±±º          ³ FB_CLASSIF, FB_CLASSE,FB_TIPO , FB_ESTADO                  º±±
±±ºÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FISA804                                                    º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FilImp(aClasif,aClase,aTipo,aEdo)
Local aRetorno	:= {}
Local cQryNLvro	:= ""
Local cTRBLVRO	:= ""
Local cf3Bas		:= "" 
Local cf3Alq		:= ""
Local cf3Val		:= ""

Local cClasif	:= ""
Local cClase	:= ""
Local cEdo	:= ""
Local cTipo	:= ""
Local nI	:= 0

DEFAULT aClasif	:= {}
DEFAULT aClase	:= {}
DEFAULT aEdo	:= {}
DEFAULT aTipo	:= {}

//=============================================================================================
//SFB - IMPUESTOS VARIABLES
//=============================================================================================

cQryNLvro := " SELECT DISTINCT FB_CLASSIF ,FB_CLASSE ,FB_CODIGO ,FB_DESCR , FB_CPOLVRO ,FB_TIPO TIPO, FB_ESTADO "
cQryNLvro += " FROM "+RetsqlName("SFB")+" SFB "
cQryNLvro += " WHERE D_E_L_E_T_='' "

If !Empty(Alltrim(xFilial("SFB")))
	cQryNLvro += " AND FB_FILIAL= '" + xFilial("SFB") + "' "
Endif 

If Len(aClasif) > 0
	For nI := 1 to Len(aClasif)
		cClasif += Iif(Empty(cClasif),"",",") + "'" + aClasif[nI] + "'"
	Next nI
	cQryNLvro += " AND FB_CLASSIF IN ( " + cClasif +  " ) "
Endif 

If Len(aClase) > 0
	For nI := 1 to Len(aClase)
		cClase += Iif(Empty(cClase),"",",") + "'" + aClase[nI] + "'"
	Next nI

	cQryNLvro += " AND FB_CLASSE IN ( " + cClase +  " ) "
Endif 

If Len(aTipo) > 0
	For nI := 1 to Len(aTipo)
		cTipo += Iif(Empty(cTipo),"",",") + "'" + aTipo[nI] + "'"
	Next nI

	cQryNLvro += " AND FB_TIPO IN ( " + cTipo +  " ) "
Endif 

If Len(aEdo) > 0
	For nI := 1 to Len(aEdo)
		cEdo += Iif(Empty(cEdo),"",",") + "'" + aEdo[nI] + "'"
	Next nI

	cQryNLvro += " AND FB_ESTADO IN ( " + cEdo +  " ) "
Endif 

If Select("TRBLVRO")>0
	DbSelectArea("TRBLVRO")
	TRBLVRO->(DbCloseArea())
Endif

cTRBLVRO := ChangeQuery(cQryNLvro)
dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBLVRO ) ,"TRBLVRO", .T., .F.)

DbSelectArea("TRBLVRO")
TRBLVRO->(dbGoTop())
If TRBLVRO->(!Eof())
	Do While TRBLVRO->(!Eof())
		lcLib := Alltrim(TRBLVRO->FB_CPOLVRO)
		cf3Bas := "F3_BASIMP" + lcLib
		cf3Alq := "F3_ALQIMP" + lcLib
		cf3Val	:= "F3_VALIMP" + lcLib
		
		aAdd(aRetorno,{TRBLVRO->FB_CODIGO,TRBLVRO->FB_DESCR,TRBLVRO->FB_CPOLVRO,TRBLVRO->FB_ESTADO,;
						 TRBLVRO->FB_CLASSIF ,TRBLVRO->FB_CLASSE,cf3Bas,cf3Alq,cf3Val})
		TRBLVRO->(DbSkip())
	End
Endif

TRBLVRO->(DbCloseArea())

Return aRetorno

