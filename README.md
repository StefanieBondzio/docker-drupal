# Tomcat auf dem Apache mit TexGrundlagen

Das Projekt ist die Grundlage für Drupalprojekt.

An die entstprechenden Dockerfiles folgendes anhängen:

EXPOSE 80

CMD ["service apache2 restart && /bin/bash"]