let
  alberand = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCrD5vBHHmwEAgwr7EwiF0WJO8vEJZwtsf/MyuwWoGOqxMZG+FXXomKm7ifaGSLpGoCHT4etNKbTPjShk9S4aSnnYfU9dc6k7Ke1Dt4KkKSVPA0ot3+46DeGu5TKl0PIRVOhlEyse81lWEVdDVg2xKqjYGsk5sOPWlV/V8/Jj1zlb0XiaQjPK9SoYeJLzH32EHoqns5s1WNWOTTnAYahESAi8qoL6ZVo9oBK0UU09YH3bVoIqZau+SXVoj9Ek8n1hf8/wnCJIaMqx1KTVO5S7TxGGNf4wjxcIwNi/XrqnyvlVZrX27gHfihSSMmauS0EuV3c6/Jf8gLl6/LfNs8VtpH";
  test-machine = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKrBYKQc/V03kJNn2Ckht6mIQ5nnfXWma/iMwj927CC0";
  users = [ alberand test-machine ];
in
{
  "client.private.age".publicKeys = users;
  "server.private.age".publicKeys = users;
}
