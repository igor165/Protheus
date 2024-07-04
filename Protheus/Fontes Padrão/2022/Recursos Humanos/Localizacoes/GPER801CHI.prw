#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER801CHI.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ?GPER801CHI ?Autor ?Jesus Peñaloza           ?Data ?19.09.14   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ?Carga configuracion de archivo magnetico (Chile)                  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso      ?Generico                                                          ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador   ?Data   ?BOPS/FNC  ? Motivo da Alteracao                     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³M.Camargo     ?2/10/15³TTQUEJ     ³Reestructuración S017                     ³±?
±±³Jonathan Glez ?7/11/15³PCREQ-7944 ³Localizacion GPE CHI p/v12                ³±?
±±?             ?       ?          ?Se prueba que funcione de manera correcta³±?
±±?             ?       ?          ³en v12, solo se realizaron cambios en el  ³±?
±±?             ?       ?          ³diccionario                               ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPER801CHI()
Local lGrava := .T.
Private cArc := 'S017'
dbSelectArea("RCC")
RCC->(dbSetOrder(1))
If RCC->(dbSeek(xFilial("RCC")+cArc))
	lGrava := MsgYesNo(STR0001+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0002, STR0003) //Ya existen registros para la tabla de configuración S017, ¿Desea cargar los registros?  //Al cargar la configuración estándar se perderan los cambios que haya realizado  //Confirma
EndIf
If lGrava
	Processa({|| CargaRCC()},STR0004, STR0005, .T.) //Espere... //Cargando Información
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Fun‡„o    ³CargaRCB  ?Autor ?Jesus Peñaloza        ?Data ?9/09/2014³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡„o ?Carga registros de la tabla S017 en la RCB                 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Sintaxe   ?CargaRCB()                                                 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Parametros?                                                           ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?CargaRCC()                                                 ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
Static Function CargaRCB()
Local aArea:= GetArea()
Local cOrd := "01"
Local aRCB := {}
Local cFil := xFilial("RCB")
Local nX   := 0


AgregaRCB(aRCB,cFil,cArc,STR0008,@cOrd,'DESCRICAO','DESCRIPCION','C',35,'@!','TEXTO()',"001")
AgregaRCB(aRCB,cFil,cArc,STR0008,@cOrd,'ANEXO','ANEXO','C',1,'@!','PERTENCE("SNICM")',"001")
AgregaRCB(aRCB,cFil,cArc,STR0008,@cOrd,'INICIO','INICIO','N',3,'999','',"001")
AgregaRCB(aRCB,cFil,cArc,STR0008,@cOrd,'LONGITUDE','LONGITUD','N',3,'999','',"001")
AgregaRCB(aRCB,cFil,cArc,STR0008,@cOrd,'FORMULA','FORMULA','C',70,'','',"001")
AgregaRCB(aRCB,cFil,cArc,STR0008,@cOrd,'DEFAUL','CONT DEFAULT','C',20,'','',"001")

	For nX := 1 to len(aRCB)
		RecLock('RCB',.T.)
		RCB->RCB_FILIAL := aRCB[nX,1]
		RCB->RCB_CODIGO := aRCB[nX,2]
		RCB->RCB_DESC   := aRCB[nX,3]
		RCB->RCB_ORDEM  := aRCB[nX,4]
		RCB->RCB_CAMPOS := aRCB[nX,5]
		RCB->RCB_DESCPO := aRCB[nX,6]
		RCB->RCB_TIPO   := aRCB[nX,7]
		RCB->RCB_TAMAN  := aRCB[nX,8]
		RCB->RCB_PICTUR := aRCB[nX,9]
		RCB->RCB_VALID  := aRCB[nX,10]
		RCB->RCB_VERSAO := aRCB[nX,11]
		RCB->(MsUnLock())
	Next nX
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Fun‡„o    ³AgregaRCB ?Autor ?Jesus Peñaloza        ?Data ?9/09/2014³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡„o ?Carga arreglo de tabla RCB e imcrementa el campo orden     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Sintaxe   ?CargaRCB(aExp1,cExp2,cExp3,cExp4,cExp5,cExp6,cExp7,cExp8,  ³±?
±±?         ?         nExp9,cExp10,cExp11,cExp12)                       ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Parametros?aExp1: Arreglo a ser llenado                               ³±?
±±?         ?cExp2: Filial a ingresar en tabla RCB                      ³±?
±±?         ?cExp3: Numero de tabla RCB                                 ³±?
±±?         ?cExp4: Descripcion de campos                               ³±?
±±?         ?cExp5: Orden                                               ³±?
±±?         ?cExp6: Nombre campo                                        ³±?
±±?         ?cExp7: Descripcion campo                                   ³±?
±±?         ?cExp8: Tipo de dato                                        ³±?
±±?         ?nExp9: Tamaño                                              ³±?
±±?         ?cExp10:Picture                                             ³±?
±±?         ?cExp11:Validacion                                          ³±?
±±?         ?cExp12:Version                                             ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?CargaRCC()                                                 ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
Static Function AgregaRCB(aArray,cFil,cArc,cDesc,cOrd,cCam,cDescri,cTip,nTam,cPict,cVal,cVers)
Local nVal := val(cOrd)
aAdd(aArray,{cFil,cArc,cDesc,cOrd,cCam,cDescri,cTip,nTam,cPict,cVal,cVers})
nVal++
cOrd := Padl(Alltrim(str(nVal)),2,'0')
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Fun‡„o    ³CargaRCB  ?Autor ?Jesus Peñaloza        ?Data ?9/09/2014³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡„o ?Carga registros de la tabla S017 en la RCC                 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Sintaxe   ?CargaRCC()                                                 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Parametros?                                                           ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?GPER801CHI()                                               ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
Static Function CargaRCC()
Local aArea:= GetArea()
Local cFil := xFilial("RCC")
Local aRCC := {}
Local cOrd := "001"
Local nX   := 0

Elimina()
CargaRCB()

AgregaRCC(aRCC,cArc,@cOrd,"RUT TRABAJADOR                     S  1 11SUBSTR(SRA->RA_CIC,1,8)                                               00000000000")
AgregaRCC(aRCC,cArc,@cOrd,"DV Trabajador                      S 12  1SUBSTR(SRA->RA_CIC,9,1)                                                          ")
AgregaRCC(aRCC,cArc,@cOrd,"Apellido Paterno                   S 13 30SRA->RA_PRISOBR                                                                  ")
AgregaRCC(aRCC,cArc,@cOrd,"Apellido Materno                   S 43 30SRA->RA_SECSOBR                                                                  ")
AgregaRCC(aRCC,cArc,@cOrd,"Nombres                            S 73 30SRA->RA_PRINOME                                                                  ")
AgregaRCC(aRCC,cArc,@cOrd,"Sexo                               S103  1SRA->RA_SEXO                                                                     ")
AgregaRCC(aRCC,cArc,@cOrd,"NACIONALIDAD                       S104  1IIF(SRA->RA_NACIONA='10','0','1')                                     0")
AgregaRCC(aRCC,cArc,@cOrd,"TIPO PAGO                          S105  2SRY->RY_TPOPAGO                                                       00")
AgregaRCC(aRCC,cArc,@cOrd,"PERIODO (DESDE)                    S107  6FORFECHA(RCH->RCH_DTINI,RCH->RCH_DTINI,6)                             000000")
AgregaRCC(aRCC,cArc,@cOrd,"PERIODO (HASTA)                    S113  6FORFECHA(RCH->RCH_DTFIM,RCH->RCH_DTFIM,6)                             000000")
AgregaRCC(aRCC,cArc,@cOrd,"REGIMEN PREVISIONAL                S119  3IIF(SRA->RA_REGIME='1','AFP',IIF(SRA->RA_REGIME='2','INP','SIP'))           ")
AgregaRCC(aRCC,cArc,@cOrd,"TIPO TRABAJADOR                    S122  1IIF(SRA->RA_TPOTRAB=' ','0',SRA->RA_TPOTRAB)                          0")
AgregaRCC(aRCC,cArc,@cOrd,"DIAS TRABAJADOS                    S123  2STRZERO(FPREVI('H','040','042'),2,0)                                  00")
AgregaRCC(aRCC,cArc,@cOrd,"Tipo de Linea                      M125  2'00'                                                                    ")
AgregaRCC(aRCC,cArc,@cOrd,"CODIGO MOVIMIENTO DE PERSONAL      M127  2FMOVPERSONAL()                                                        00")
AgregaRCC(aRCC,cArc,@cOrd,"Fecha Desde                        M129 10fMovFini()                                                              ")
AgregaRCC(aRCC,cArc,@cOrd,"Fecha Hasta                        M139 10fMovFfin()                                                              ")
AgregaRCC(aRCC,cArc,@cOrd,"TRAMO ASIGNACION FAMILIAR          S149  1IIF(SRA->RA_TRAMFAM='0',' ',SRA->RA_TRAMFAM)                            ")
AgregaRCC(aRCC,cArc,@cOrd,"N°CARGAS SIMPLES                   S150  2STRZERO(FCARGAS('S'),2,0)                                             00")
AgregaRCC(aRCC,cArc,@cOrd,"N°CARGAS MATERNALES                S152  1FCARGAS('M')                                                          0")
AgregaRCC(aRCC,cArc,@cOrd,"N°CARGAS INVALIDAS                 S153  1FCARGAS('I')                                                          0")
AgregaRCC(aRCC,cArc,@cOrd,"ASIGNACION FAMILIAR                S154  6STRZERO(FPREVI('V','095'),6,0)                                        000000")
AgregaRCC(aRCC,cArc,@cOrd,"ASIGNACION FAMILIAR RETROACTIVA    S160  6STRZERO(FPREVI('V','096'),6,0)                                        000000")
AgregaRCC(aRCC,cArc,@cOrd,"REINTEGRO CARGAS FAMILIARES        S166  6STRZERO(FPREVI('V','754'),6,0)                                        000000")
AgregaRCC(aRCC,cArc,@cOrd,"Solicitud Trabajador Joven         S172  1'N'                                                                         ")
AgregaRCC(aRCC,cArc,@cOrd,"COGIDO DE LA AFP                   N173  2STRZERO(FPREVI('E','503','511'),2,0)                                  00")
AgregaRCC(aRCC,cArc,@cOrd,"RENTA IMPONIBLE AFP                N175  8STRZERO(FPREVI('V','501','510'),8,0)                                  00000000")
AgregaRCC(aRCC,cArc,@cOrd,"COTIZACION OBLIGATORIA AFP         N183  8STRZERO(FPREVI('V','503','504','511'),8,0)                            00000000")
AgregaRCC(aRCC,cArc,@cOrd,"COTIZ SEG INVAL Y COTIZ DEL SIS    N191  8STRZERO(FPREVI('V','522','528'),8,0)                                  00000000")
AgregaRCC(aRCC,cArc,@cOrd,"CUENTA DE AHORRO VOLUNTARIO AFP    N199  8STRZERO(FPREVI('V','545'),8,0)                                        00000000")
AgregaRCC(aRCC,cArc,@cOrd,"RENTA IMP. SUST.AFP                N207  8'00000000'                                                            00000000")
AgregaRCC(aRCC,cArc,@cOrd,"TASA PACTADA (SUSTIT.)             N215  5'00000'                                                               00000000")
AgregaRCC(aRCC,cArc,@cOrd,"APORTE INDEMN. (SUSTIT.)           N220  9'000000000'                                                           00000000")
AgregaRCC(aRCC,cArc,@cOrd,"N°PERIODOS (SUSTIT.)               N229  2'00'                                                                  00")
AgregaRCC(aRCC,cArc,@cOrd,"Periodo desde (Sustit.)            N231 10                                                                      ")
AgregaRCC(aRCC,cArc,@cOrd,"Periodo Hasta (Sustit.)            N241 10                                                                      ")
AgregaRCC(aRCC,cArc,@cOrd,"Puesto de Trabajo Pesado           N251 40                                                                      ")
AgregaRCC(aRCC,cArc,@cOrd,"% COTIZACION TRABAJO PESADO        N291  5'00,00'                                                               00,00")
AgregaRCC(aRCC,cArc,@cOrd,"COTIZACION TRABAJO PESADO          N296  6'000000'                                                              000000")
AgregaRCC(aRCC,cArc,@cOrd,"CODIGO DE LA INSTITUCION APVI      I302  3STRZERO(FAPVI('E','540','541'),3,0)                                   000")
AgregaRCC(aRCC,cArc,@cOrd,"NUMERO DE CONTRATO APVI            I305 20FAPVIC()                                                              ")
AgregaRCC(aRCC,cArc,@cOrd,"FORMA DE PAGO APVI                 I325  1STRZERO(FAPVI('F'),1,0)                                               0")
AgregaRCC(aRCC,cArc,@cOrd,"COTIZACION APVI                    I326  8STRZERO(FAPVI('V'),8,0)                                               00000000")
AgregaRCC(aRCC,cArc,@cOrd,"COTIZACION DEPOSITOS CONVENIDOS    I334  8STRZERO(FPREVI('V','155'),8,0)                                        00000000")
AgregaRCC(aRCC,cArc,@cOrd,"CODIGO INSTITUCION AUTORIZADA APVC C342  3STRZERO(FAPVC('E','542','543'),3,0)                                   000")
AgregaRCC(aRCC,cArc,@cOrd,"NUMERO DE CONTRATO APVC            C345 20FAPVCC()                                                              ")
AgregaRCC(aRCC,cArc,@cOrd,"FORMA DE PAGO APVC                 C365  1STRZERO(FAPVC('F'),1,0)                                               0")
AgregaRCC(aRCC,cArc,@cOrd,"COTIZACION TRABAJADOR APVC         C366  8STRZERO(FAPVC('V'),8,0)                                               00000000")
AgregaRCC(aRCC,cArc,@cOrd,"COTIZACION EMPLEADOR APVC          C374  8STRZERO(FPREVI('V','544'),8,0)                                        00000000")
AgregaRCC(aRCC,cArc,@cOrd,"RUT AFILIADO VOLUNTARIO            N382 11'00000000000'                                                         00000000000")
AgregaRCC(aRCC,cArc,@cOrd,"DV AFILIADO VOLUNTARIO             N393  1                                                                      ")
AgregaRCC(aRCC,cArc,@cOrd,"APELLIDO PATERNO                   N394 30                                                                      ")
AgregaRCC(aRCC,cArc,@cOrd,"APELLIDO MATERNO                   N424 30                                                                      ")
AgregaRCC(aRCC,cArc,@cOrd,"NOMBRES                            N454 30                                                                      ")
AgregaRCC(aRCC,cArc,@cOrd,"CODIGO MOVIMIENTO DE PERSONAL      N484  2'00'                                                                  00")
AgregaRCC(aRCC,cArc,@cOrd,"FECHA DESDE                        N486 10                                                                      ")
AgregaRCC(aRCC,cArc,@cOrd,"FECHA HASTA                        N496 10                                                                      ")
AgregaRCC(aRCC,cArc,@cOrd,"CODIGO DE LA AFP                   N506  2'00'                                                                  00")
AgregaRCC(aRCC,cArc,@cOrd,"MONTO CAPITALIZACION VOLUNTARIA    N508  8'00000000'                                                            00000000")
AgregaRCC(aRCC,cArc,@cOrd,"MONTO AHORRO VOLUNTARIO            N516  8'00000000'                                                            00000000")
AgregaRCC(aRCC,cArc,@cOrd,"NUMERO DE PERIODOS DE COTIZACION   N524  2'00'                                                                  00")
AgregaRCC(aRCC,cArc,@cOrd,"CODIGO EX-CAJA REGIMEN             N526  4STRZERO(FPREVI('E','560','563'),4,0)                                  0000")
AgregaRCC(aRCC,cArc,@cOrd,"TASA COTIZACION EX-CAJA PREVISION  N530  5STRZERO(FPREVI('H','560','563'),5,2)                                  00,00")
AgregaRCC(aRCC,cArc,@cOrd,"RENTA IMPONIBLE IPS                N535  8STRZERO(FPREVI('V','580','595'),8,0)                                  00000000")
AgregaRCC(aRCC,cArc,@cOrd,"COTIZACION OBLIGATORIA IPS         N543  8STRZERO(FPREVI('V','560','563'),8,0)                                  00000000")
AgregaRCC(aRCC,cArc,@cOrd,"RENTA IMPONIBLE DESAHUCIO          N551  8'00000000'                                                            00000000")
AgregaRCC(aRCC,cArc,@cOrd,"CODIGO EX-CAJA REGIMEN DESAHUCIO   N559  4'0000'                                                                0000")
AgregaRCC(aRCC,cArc,@cOrd,"TASA COTIZACION DESAHUCIO EX-CAJAS N563  5'00,00'                                                               00,00")
AgregaRCC(aRCC,cArc,@cOrd,"COTIZACION DESAHUCIO               N568  8'00000000'                                                            00000000")
AgregaRCC(aRCC,cArc,@cOrd,"COTIZACION FONASA                  N576  8STRZERO(FPREVI('V','589'),8,0)                                        00000000")
AgregaRCC(aRCC,cArc,@cOrd,"COTIZACION ACC. TRABAJO (ISL)      N584  8STRZERO(FPREVI('V','642'),8,0)                                        00000000")
AgregaRCC(aRCC,cArc,@cOrd,"BONIFICACION LEY 15.386            N592  8'00000000'                                                            00000000")
AgregaRCC(aRCC,cArc,@cOrd,"DESCUENTO POR CARGAS FAMILIARES DE N600  8STRZERO(FPREVI('V','097'),8,0)                                        00000000")
AgregaRCC(aRCC,cArc,@cOrd,"BONOS GOBIERNO                     N608  8'00000000'                                                            00000000")
AgregaRCC(aRCC,cArc,@cOrd,"CODIGO INSTITUCION DE SALUD        N616  2STRZERO(FPREVI('E','583','597'),2,0)                                  00")
AgregaRCC(aRCC,cArc,@cOrd,"NUMERO DEL FUN                     N618 16SRA->RA_NUMFUN                                                        ")
AgregaRCC(aRCC,cArc,@cOrd,"RENTA IMPONIBLE ISAPRE             N634  8STRZERO(FPREVI('V','581','596'),8,0)                                  00000000")
AgregaRCC(aRCC,cArc,@cOrd,"MONEDA DEL PLAN PACTADO ISAPRE     N642  1IIF(SRA->RA_ISATIPO='2','2','1')                                      0")
AgregaRCC(aRCC,cArc,@cOrd,"COTIZACION PACTADA                 N643  8FCOTPACT('586')                                                       00000000")
AgregaRCC(aRCC,cArc,@cOrd,"COTIZACION OBLIGATORIA ISAPRE      N651  8STRZERO(FPREVI('V','590'),8,0)                                        00000000")
AgregaRCC(aRCC,cArc,@cOrd,"COTIZACION ADICIONAL VOLUNTARIA    N659  8STRZERO(FPREVI('V','584','585'),8,0)                                  00000000")
AgregaRCC(aRCC,cArc,@cOrd,"MONTO GARANTIA EXPLICITA DE SALUD GN667  8'00000000'                                                            00000000")
AgregaRCC(aRCC,cArc,@cOrd,"CODIGO CCAF                        N675  2RCJ->RCJ_CCAF                                                         00")
AgregaRCC(aRCC,cArc,@cOrd,"RENTA IMPONIBLE CCAF               N677  8STRZERO(FPREVI('V','582'),8,0)                                        00000000")
AgregaRCC(aRCC,cArc,@cOrd,"CREDITOS PERSONALES CCAF           N685  8STRZERO(FPREVI('V','610'),8,0)                                        00000000")
AgregaRCC(aRCC,cArc,@cOrd,"DESCUENTO DENTAL CCAF              N693  8STRZERO(FPREVI('V','613'),8,0)                                        00000000")
AgregaRCC(aRCC,cArc,@cOrd,"DESCUENTOS POR LEASING (PROGRAMA AHN701  8STRZERO(FPREVI('V','611'),8,0)                                        00000000")
AgregaRCC(aRCC,cArc,@cOrd,"DESCUENTOS POR SEGURO DE VIDA CCAF N709  8STRZERO(FPREVI('V','612'),8,0)                                        00000000")
AgregaRCC(aRCC,cArc,@cOrd,"OTROS DESCUENTOS CCAF              N717  8STRZERO(FPREVI('V','614'),8,0)                                        00000000")
AgregaRCC(aRCC,cArc,@cOrd,"COTIZACION A CCAF DE NO AFILIADOS AN725  8STRZERO(FPREVI('V','588'),8,0)                                        00000000")
AgregaRCC(aRCC,cArc,@cOrd,"DESCUENTO CARGAS FAMILIARES CCAF   N733  8STRZERO(FPREVI('V','098'),8,0)                                        00000000")
AgregaRCC(aRCC,cArc,@cOrd,"OTROS DESCUENTOS CCAF 1(USO FUTURO)N741  8'00000000'                                                            00000000")
AgregaRCC(aRCC,cArc,@cOrd,"OTROS DESCUENTOS CCAF 2(USO FUTURO)N749  8'00000000'                                                            00000000")
AgregaRCC(aRCC,cArc,@cOrd,"BONOS GOBIERNO (USO FUTURO)        N757  8'00000000'                                                            00000000")
AgregaRCC(aRCC,cArc,@cOrd,"CODIGO DE SUCURSAL (USO FUTURO)    N765 20                                                                      ")
AgregaRCC(aRCC,cArc,@cOrd,"CODIGO MUTUALIDAD                  N785  2RCJ->RCJ_MUTUAL                                                       00")
AgregaRCC(aRCC,cArc,@cOrd,"RENTA IMPONIBLE MUTUAL             N787  8STRZERO(FPREVI('V','640','648'),8,0)                                  00000000")
AgregaRCC(aRCC,cArc,@cOrd,"COTIZACION ACCIDENTE DEL TRABAJO (MN795  8STRZERO(FPREVI('V','643'),8,0)                                        00000000")
AgregaRCC(aRCC,cArc,@cOrd,"SUCURSAL PARA PAGO MUTUAL          N803  3                                                                      000")
AgregaRCC(aRCC,cArc,@cOrd,"RENTA IMPONIBLE SEGURO CESANTIA (INN806  8STRZERO(FPREVI('V','660','674','661',,,100),8,0)                      00000000")
AgregaRCC(aRCC,cArc,@cOrd,"APORTE TRABAJADOR SEGURO CESANTIA  N814  8STRZERO(FPREVI('V','662','675',,,,101),8,0)                           00000000")
AgregaRCC(aRCC,cArc,@cOrd,"APORTE EMPLEADOR SEGURO CESANTIA   N822  8STRZERO(FPREVI('V','663','676',,,,102),8,0)                           00000000")
AgregaRCC(aRCC,cArc,@cOrd,"RUT PAGADORA SUBSIDIO              N830 11FINSTIT('R','590')                                                    00000000000")
AgregaRCC(aRCC,cArc,@cOrd,"DV PAGADORA SUBSIDIO               N841  1FINSTIT('D','590')                                                    0")
AgregaRCC(aRCC,cArc,@cOrd,"CENTRO DE COSTOS, SUCURSAL, AGENCIAN842 20POSICIONE('CTT',1,XFILIAL('CTT')+SRA->RA_CC,'CTT_DESC01')             ")

ProcRegua(len(aRCC))
For nX := 1 to len(aRCC)
	RecLock('RCC',.T.)
	RCC->RCC_FILIAL := cFil
	RCC->RCC_CODIGO := aRCC[nX,1]
	RCC->RCC_SEQUEN := aRCC[nX,2]
	RCC->RCC_CONTEU := aRCC[nX,3]
	RCC->(MsUnLock())
	IncProc()
Next nX
RestArea(aArea)
MsgInfo(STR0006, STR0007) //Proceso terminado con éxito //Éxito
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Fun‡„o    ³AgregaRCC ?Autor ?Jesus Peñaloza        ?Data ?9/09/2014³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡„o ?Carga arreglo de tabla RCC e imcrementa el campo orden     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Sintaxe   ?CargaRCC(aExp1,cExp2,cExp3,cExp4)                          ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Parametros?aExp1: Arreglo a ser llenado                               ³±?
±±?         ?cExp2: Numero de tabla RCC                                 ³±?
±±?         ?cExp3: Orden                                               ³±?
±±?         ?cExp4: Contenido                                           ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?CargaRCC()                                                 ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
Static Function AgregaRCC(aArray,cCod,cSeq,cCon)
Local nVal := val(cSeq)
aAdd(aArray,{cCod,cSeq,cCon})
nVal++
cSeq := Padl(Alltrim(str(nVal)),3,'0')
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±³Fun‡„o    ?Elimina  ?Autor ?Jesus Peñaloza        ?Data ?9/09/2014³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±³Descri‡„o ?Elimina registros de RCB y RCC si el codigo es S017        ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Sintaxe   ?Elimina()                                                  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±³Parametros?                                                           ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?CargaRCC()                                                 ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
/*/
Static Function Elimina()
Local aArea:= GetArea()
Local cFilRCB := xFilial("RCB")
Local cFilRCC := xFilial("RCC")

dbSelectArea("RCB")
dbSelectArea("RCC")
RCB->(dbSetOrder(1))
RCC->(dbSetOrder(1))

If RCB->(dbSeek(cFilRCB+cArc))
	While (!RCB->(EOF()) .and. RCB->RCB_FILIAL == cFilRCB .and. RCB->RCB_CODIGO == cArc)
		RecLock("RCB", .F.)
		RCB->(dbDelete())
		RCB->(MsUnlock())
		RCB->(dbSkip())
	EndDo
EndIf

If RCC->(dbSeek(cFilRCC+cArc))
	While (!RCC->(EOF()) .and. RCC->RCC_FILIAL == cFilRCC .and. RCC->RCC_CODIGO == cArc)
		RecLock("RCC", .F.)
		RCC->(dbDelete())
		RCC->(MsUnlock())
		RCC->(dbSkip())
	EndDo
EndIf
RestArea(aArea)
Return
