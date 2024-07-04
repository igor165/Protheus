unit i18n;

interface

const
  //Idioma do Protheus. 
  POR = 0;
  ESP = 1;
  ING = 2;

function SetTexto(nIndice : Integer; nIdioma : Integer) : String;

implementation

function SetTexto(nIndice : Integer; nIdioma : Integer) : String;
var
  Texto : String;
begin

  //Strings internacionalizadas. 

  if nIdioma = ING then
  begin
    case nIndice of
       1 : Texto := 'Report inexistent in path -> ';
       2 : Texto := 'Generating Report: ';
       3 : Texto := 'Inexistent path';
       4 : Texto := 'Directories - Protheus';
       5 : Texto := 'Select the path of Protheus Server StartPath';
       6 : Texto := 'Select the exportacion path';
       7 : Texto := 'Select the path of Protheus Server RootPath';
       8 : Texto := '';
       9 : Texto := 'OK';
      10 : Texto := 'Cancel';
      11 : Texto := 'Login';
      12 : Texto := 'Login Data';
      13 : Texto := 'User';
      14 : Texto := 'Password';
      15 : Texto := 'Use connection via ODBC to create a report';
      16 : Texto := 'Please, wait until the end of installation and run the report again';
      17 : Texto := 'Unable to find the directory for installation. Report CANNOT be executed';
      18 : Texto := 'Unable to find installation files -> ';
      19 : Texto := 'Unable to be connected to Protheus Server';
      20 : Texto := 'File .REG successfully created!';
      21 : Texto := 'Failure while creating file .REG!';
      22 : Texto := 'Restructure successfully performed!';
      23 : Texto := 'Failure while performing restructure!';
      24 : Texto := 'Driver ODBC not found!';
      25 : Texto := 'There is more than one directory informed in the variable of TMP environment';
      26 : Texto := 'Directories';
      27 : Texto := 'Options';
      28 : Texto := 'Server Setups';
      29 : Texto := 'Generate log';
      30 : Texto := 'Access SXs dictonary via DLL';
      31 : Texto := 'Server';
      32 : Texto := 'Port';
      33 : Texto := 'Accessing SXs dictonaries though DLL is necessary to inform Protheus server configurations';
      34 : Texto := 'Print Disabled';
      35 : Texto := 'Auto Configuration';
    else
      Texto := 'Text No Registered';
    end;
  end
  else if nIdioma = ESP then
  begin
    case nIndice of
       1 : Texto := 'Informe inexistente en la ruta de acceso -> ';
       2 : Texto := 'Generando el informe: ';
       3 : Texto := 'Ruta de acceso inexistente';
       4 : Texto := 'Directorios - Protheus';
       5 : Texto := 'Indique la ruta do StartPath do servidor Protheus';
       6 : Texto := 'Indique la ruta para exportacion';
       7 : Texto := 'Indique la ruta do RootPath do servidor Protheus';
       8 : Texto := '';
       9 : Texto := 'OK';
      10 : Texto := 'Anular';
      11 : Texto := 'Login';
      12 : Texto := 'Datos de Login';
      13 : Texto := 'Usuario';
      14 : Texto := 'Contrase�a';
      15 : Texto := 'Utilizar conexi�n via ODBC para crear el informe';
      16 : Texto := 'Por favor, espere que la instalaci�n termine y ejecute nuevamente el informe';
      17 : Texto := 'No fue posible localizar el directorio para instalaci�n. El informe NO podr� ejecutarse';
      18 : Texto := 'No fue posible localizar el archivo de instalaci�n -> ';
      19 : Texto := 'No fue posible conectarse al Servidor Protheus';
      20 : Texto := '�Archivo .REG creado con �xito!';
      21 : Texto := '�Falla al crear archivo .REG!';
      22 : Texto := '�Restauraci�n efectuada con �xito!';
      23 : Texto := '�Falla al realizar la restauraci�n!';
      24 : Texto := '�Driver ODBC no localizado!';
      25 : Texto := 'Existe m�s de un directorio informado en la variable del entorno TMP';
      26 : Texto := 'Directorios';
      27 : Texto := 'Opciones';
      28 : Texto := 'Configuraciones del Servidor';
      29 : Texto := 'Genera log';
      30 : Texto := 'Accede al dicion�rio SXs v�a DLL';
      31 : Texto := 'Servidor';
      32 : Texto := 'Puerta';
      33 : Texto := 'Para acessar os dicion�rios SXs via DLL � necess�rio informar as configura��es do servidor Protheus.';
      34 : Texto := 'Dishabilita Impresi�n';
      35 : Texto := 'Configuraci�n Autom�tica';
    else
      Texto := 'Texto No Registrado';
    end;
  end
  else
  begin
    case nIndice of
       1 : Texto := 'Relat�rio n�o existe no caminho -> ';
       2 : Texto := 'Gerando o Relat�rio: ';
       3 : Texto := 'Caminho n�o existente';
       4 : Texto := 'Diret�rios - Protheus';
       5 : Texto := 'Selecione o caminho do StartPath do servidor Protheus:';
       6 : Texto := 'Selecione o caminho para exporta��o de relat�rios:';
       7 : Texto := 'Selecione o caminho do RootPath do servidor Protheus:';
       8 : Texto := '';
       9 : Texto := 'OK';
      10 : Texto := 'Cancelar';
      11 : Texto := 'Login';
      12 : Texto := 'Informa��es de Login';
      13 : Texto := 'Usu�rio';
      14 : Texto := 'Senha';
      15 : Texto := 'Utilizar conex�o via ODBC para criar o relat�rio';
      16 : Texto := 'Favor aguardar o t�rmino da instala��o dos Drivers do Crystal e execute novamente o relat�rio';
      17 : Texto := 'N�o foi poss�vel localizar o diret�rio para instala��o. O relat�rio NAO poder� ser executado';
      18 : Texto := 'N�o foi poss�vel localizar o arquivo de instala��o -> ';
      19 : Texto := 'N�o foi poss�vel se conectar ao Servidor Protheus';
      20 : Texto := 'Arquivo .REG criado com sucesso!';
      21 : Texto := 'Falha ao criar arquivo .REG!';
      22 : Texto := 'Restaura��o efetuada com sucesso!';
      23 : Texto := 'Falha ao realizar restaura��o!';
      24 : Texto := 'Driver ODBC n�o localizado!';
      25 : Texto := 'Existe mais de um diret�rio informado na vari�vel de ambiente TMP';
      26 : Texto := 'Diret�rios';
      27 : Texto := 'Op��es';
      28 : Texto := 'Configura��es do Servidor Protheus';
      29 : Texto := 'Gerar log';
      30 : Texto := 'Acessar SXs via DLL';
      31 : Texto := 'Servidor';
      32 : Texto := 'Porta';
      33 : Texto := 'Para acessar os dicion�rios SXs via DLL � necess�rio informar as configura��es do servidor Protheus.';
      34 : Texto := 'Desabilitar Impress�o';
      35 : Texto := 'Configura��o Autom�tica';
    else
      Texto := 'Texto N�o Cadastrado';
    end;
  end;
  result := Texto
end;  
end.
 
